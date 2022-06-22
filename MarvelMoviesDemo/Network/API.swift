//
//  API.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import Foundation
import Combine

public class API {
    static public let shared = API()
    // Note: change these to your preference
    static private var URL_PREFIX  = (BuildConfiguration.shared.environment == .development ? "https://" : "https://")
    static private var HOST = (BuildConfiguration.shared.environment == .development ? "iosdevtest.herokuapp.com" : "https://iosdevtest.herokuapp.com")
    
    @Published private var authenticatedSession: URLSession?
    private var signedOutSession: URLSession
    private var decoder: JSONDecoder
    
    private var oauthStateCancellable: AnyCancellable?
    
    init () {
        decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        signedOutSession = URLSession(configuration: Self.makeSessionConfiguration(token: nil))
        oauthStateCancellable = OAuthClient.shared.$authState.sink { state in
            DispatchQueue.main.async {
                switch state {
                case .authenticated(let token):
                    self.authenticatedSession = URLSession(configuration: Self.makeSessionConfiguration(token: token))
                case .refreshing, .signinInProgress, .signedOut:
                    self.authenticatedSession = nil
                }
            }
        }
    }
    
    public func setAuthCredentials(username: String,
                                          password: String) {
        signedOutSession = URLSession(configuration: Self.makeSessionConfiguration(token: nil,
                                                                                   username: username,
                                                                                   password: password))
    }
    
    static private func makeSessionConfiguration(token: String?,
                                                 username: String? = nil,
                                                 password: String? = nil) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        var headers = ["User-Agent": "iOS:MarvelMoviesDemo:v" + Bundle.main.appVersionLong]
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        } else if (username != nil && password != nil) {
            let authStr = "\(username ?? ""):\(password ?? "")"
            let credentials = authStr.data(using: String.Encoding.utf8)?.base64EncodedString()
            headers["Authorization"] = "Basic \(credentials ?? "")"
        }
        configuration.httpAdditionalHeaders = headers
        configuration.urlCache = .shared
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return configuration
    }
    
    static private func makeURL(host: String = HOST,
                                endpoint: Endpoint,
                                forceSignedOutURL: Bool,
                                isJSONAPI: Bool) -> URL {
        var url: URL
        
        if (host != HOST) {
            url = URL(string: "\(host)")!
        } else if forceSignedOutURL {
            url = URL(string: "\(Self.URL_PREFIX)www.\(host)")!
        } else {
            switch OAuthClient.shared.authState {
            case .authenticated:
                url = URL(string: "\(Self.URL_PREFIX)\(host)")!
            default:
                url = URL(string: "\(Self.URL_PREFIX)\(host)")!
            }
        }
        // https://testsite.com?blablabla becomes https://testsite.com/?blablabla if I don't add this.
        if (host == HOST) {
            url = url.appendingPathComponent(endpoint.path())
        }
        let component = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        return component.url!
    }
    
    static private func makeRequest<P: Any>(url: URL,
                                            httpMethod: String = "GET",
                                            queryParamsAsBody: Bool,
                                            params: [String: P]? = nil) -> URLRequest {
        var request: URLRequest
        var url = url
        if let params = params {
            if queryParamsAsBody {
                request = URLRequest(url: url)
                request.httpBody = try? JSONSerialization.data(withJSONObject: params)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } else {
                for (_, value) in params.enumerated() {
                    url = url.appending(value.key, value: String(describing: value.value))
                }
                request = URLRequest(url: url)
            }
        } else {
            request = URLRequest(url: url)
        }
        //        if !queryParamsAsBody {
        //            request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        //            request.setValue("public-read", forHTTPHeaderField: "x-amz-acl")
        //        }
        request.httpMethod = httpMethod
        return request
    }
    
    func request<T: Decodable, P: Any>(host: String = HOST,
                                       endpoint: Endpoint,
                                       forceSignedOutURL: Bool = false,
                                       httpMethod: String = "GET",
                                       isJSONEndpoint: Bool = true,
                                       queryParamsAsBody: Bool = false,
                                       params: [String: P]? = nil) -> AnyPublisher<T, NetworkError> {
        
        if authenticatedSession != nil
            || OAuthClient.shared.authState == .signedOut
            || OAuthClient.shared.authState == .signinInProgress
            || OAuthClient.shared.authState == .refreshing {
            
            let url = Self.makeURL(host: host,
                                   endpoint: endpoint,
                                   forceSignedOutURL: forceSignedOutURL,
                                   isJSONAPI: isJSONEndpoint)
            let request = Self.makeRequest(url: url,
                                           httpMethod: httpMethod,
                                           queryParamsAsBody: queryParamsAsBody,
                                           params: params)
            
            if let session = authenticatedSession, !forceSignedOutURL {
                return executeRequest(publisher: session.dataTaskPublisher(for: request))
            } else {
                return executeRequest(publisher: signedOutSession.dataTaskPublisher(for: request))
            }
        } else {
            return $authenticatedSession
                .compactMap{ $0 }
                .map {
                    $0.dataTaskPublisher(for: Self.makeRequest(url: Self.makeURL(host: host,
                                                                                 endpoint: endpoint,
                                                                                 forceSignedOutURL: forceSignedOutURL,
                                                                                 isJSONAPI: isJSONEndpoint),
                                                               httpMethod: httpMethod,
                                                               queryParamsAsBody: queryParamsAsBody,
                                                               params: params))
                }
                .flatMap { self.executeRequest(publisher: $0) }
                .eraseToAnyPublisher()
        }
    }
    
    private func executeRequest<T: Decodable>(publisher: URLSession.DataTaskPublisher) -> AnyPublisher<T, NetworkError> {
        publisher
            .tryMap{ data, response in
                return try NetworkError.processResponse(data: data, response: response)
            }
            .catch{ error -> AnyPublisher<Result<Data, Error>, Error> in
                switch error {
                case NetworkError.rateLimitted,
                    NetworkError.serverBusy:
                    print("NetworkError.rateLimitted || serverBusy")
                    return Fail(error: error)
                        .delay(for: 3, scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                default:
                    print("NetworkError.default")
                    return Just(.failure(error))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .retry(2)
            .tryMap({ result in
                return try result.get().self
            })
            .decode(type: T.self, decoder: decoder)
            .mapError{ error -> NetworkError in
                print("----- BEGIN PARSING ERROR -----")
                let networkError = NetworkError.parseError(reason: error)
                print("error: ", error)
                print("----- END PARSING ERROR -----")
                return networkError
            }
            .eraseToAnyPublisher()
    }
    
}
