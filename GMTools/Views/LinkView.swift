//
//  LinkView.swift
//  GMTools
//
//  Created by Bobby Walker on 3/11/25.
//

import AuthenticationServices
import SwiftUI

struct LinkView: View {
    @Bindable var authViewModel = AuthViewModel.shared
    @Binding var method: String?

    @State var result: Result<Void, Error>?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    Image(.background)
                        .resizable()
                        .scaledToFit()
                        .opacity(0.5)
                }
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "person.badge.key")
                            .padding(.trailing)
                        Text("Sign In Options")
                    }
                        .frame(maxWidth: .infinity)
                        .font(.title2.bold())
                        .padding()
                    Text("Enter your email address below and click Sign In to receive an email with a link to login without a password.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                        .padding()
                    Section {
                        Label("Email", systemImage: "envelope")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 20)
                        TextField("Email", text: $authViewModel.email)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                    
                    
                    Section {
                        HStack(alignment: .center) {
                            VStack() {
                                Button {
                                    signInButtonTapped()
                                } label: {
                                    Text("Sign In With Magic Link")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 30)
                                }
                                .buttonStyle(.borderedProminent)
                                
                                Button {
                                    withAnimation {
                                        method = "password"
                                    }
                                } label: {
                                    Text("Sign In With Password")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 30)
                                }
                                .buttonStyle(.borderedProminent)
                                
                                AppleSigninButton()
                                
                                //                        GoogleSignInButton() {
                                //                            AuthViewModel.google.signIn() { result in
                                //                                switch result {
                                //                                case .success(let session):
                                //                                        Task {
                                //                                            await AuthViewModel.google.finishSignIn(idToken: session.idToken)
                                //                                        }
                                //                                        print("Successfully signed in with Google")
                                //                                case .failure(let error):
                                //                                    print("Google sign-in error: \(error)")
                                //                                }
                                //                            }
                                //                        }
                            }
                            
                            if AuthViewModel.shared.isLoading {
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
                    
                    Spacer()
                }
                .padding(.horizontal)
                .onOpenURL(perform: { url in
                    Task {
                        do {
                            try await supabase.auth.session(from: url)
                        } catch {
                            self.result = .failure(error)
                        }
                    }
                })
                .navigationTitle(Text("GM Tools"))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    func signInButtonTapped() {
        Task {
            AuthViewModel.shared.isLoading = true
            defer { AuthViewModel.shared.isLoading = false }
            
            do {
                try await supabase.auth.signInWithOTP(
                    email: authViewModel.email,
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
    LinkView(method: .constant(nil))
}
