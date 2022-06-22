//
//  LoginView.swift
//  MarvelMoviesDemo
//
//  Created by Liviu Bosbiciu on 22.06.2022.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var userData: AuthenticationInfo = AuthenticationInfo.shared
    @State private var username: String = "iosdeveloper"
    @State private var password: String = "novartis2022"
    @State var loading: Bool = false
    @State var showToast = false
    @State var toastMessage: String = ""
    @EnvironmentObject private var oauthClient: OAuthClient
    
    var body: some View {
        VStack {
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
        }
        .padding(.horizontal)
        .onChange(of: oauthClient.authState) { authState in
            // scenario: User registers, but does not complete the profile.
            // he then DELETES the app (not only quit, but delete it)
            // then he installs it again and logs in.
            if case .authenticated(_) = authState {
                // todo: do something on auth finished.
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

