//
//  LoginView.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import SwiftUI
import AlertToast

struct LoginView: View {
    @ObservedObject var userData: AuthenticationInfo = AuthenticationInfo.shared
    @State private var username: String = ""
    @State private var password: String = ""
    @State var loading: Bool = false
    @State var showToast = false
    @State var toastMessage: String = ""
    @EnvironmentObject private var oauthClient: OAuthClient
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.title)
                .padding(.vertical, 40)
            
            VStack(spacing: 0) {
                TextField(
                    "Username",
                    text: $username
                ) { _ in
                } onCommit: {
                    //
                }
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(height: 42)
                
                Color(.systemGray4)
                    .frame(height: 0.5)
                
                SecureField(
                    "Password",
                    text: $password
                )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(height: 42)
            }
            .padding(.leading, 16)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            
            if (!self.loading) {
                Button(action: {
                    self.loading = true
                    oauthClient.handleLogin(username: username, password: password)
                }, label: {
                    Text("Log in with email")
                        .frame(maxWidth: .infinity, minHeight: 40)
                })
                    .outlinedButtonStyle()
                    .padding(.top, 15)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .outlinedButtonStyle()
                    .padding(.top, 15)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true,
               alert: {
            AlertToast(displayMode: .banner(.pop),
                       type: .error(Color(.systemRed)),
                       title: "Invalid Credentials")
        }, onTap: {
        }, completion: {
        })
        .onChange(of: oauthClient.authState) { authState in
            if case .authenticated(_) = authState {
            } else if case .signedOut = authState {
                loading = false
                self.toastMessage = "Invalid credentials"
                showToast = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

