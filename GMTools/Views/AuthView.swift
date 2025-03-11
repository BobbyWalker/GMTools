//
//  AuthView.swift
//  GMTools
//
//  Created by Bobby Walker on 3/9/25.
//

import GoogleSignInSwift
import Supabase
import SwiftUI

struct AuthView: View {
    @Bindable var authViewModel = AuthViewModel.shared
    
    @State var email = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?
    
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            
            Section {
                HStack(alignment: .center) {
                    VStack() {
                        
                        Button("Sign In") {
                            signInButtonTapped()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Sign in with Apple", systemImage: "apple.logo") {
                            AuthViewModel.apple.startSignInWithAppleFlow { result in
                                switch result {
                                case .success(let session):
                                    Task {
                                        await AuthViewModel.apple.signInWithApple(idToken: session.idToken, nonce: session.nonce)
                                    }
                                case .failure(let error):
                                    print("Apple ID sign-in error: \(error)")
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                        
                        GoogleSignInButton() {
                            AuthViewModel.google.signIn() { result in
                                switch result {
                                case .success(let session):
                                    
                                case .failure(let error):
                                    print("Google sign-in error: \(error)")
                                }
                            }
                        }
                    }
                    
                    if isLoading {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
            
            if let result {
                Section {
                    switch result {
                    case .success:
                        Text("Check your inbox.")
                    case .failure(let error):
                        Text(error.localizedDescription)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .onOpenURL(perform: { url in
            Task {
              do {
                try await supabase.auth.session(from: url)
              } catch {
                self.result = .failure(error)
              }
            }
          })
    }
    
    func signInButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await supabase.auth.signInWithOTP(
                    email: email,
                    redirectTo: URL(string: "com.bswventures.gmtools://login-callback")
                )
                result = .success(())
            } catch {
                result = .failure(error)
            }
        }
    }
}

#Preview {
    AuthView()
}
