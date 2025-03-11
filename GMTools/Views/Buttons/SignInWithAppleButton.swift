//
//  SignInWithAppleButton.swift
//  GMTools
//
//  Created by Bobby Walker on 3/11/25.
//

import SwiftUI

struct AppleSigninButton: View {
    var body: some View {
        Button {
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
        } label: {
            Label("Sign in with Apple", systemImage: "apple.logo")
                .frame(maxWidth: .infinity)
                .frame(height: 30)
        }
        .buttonStyle(.borderedProminent)
        .tint(.black)
        .foregroundStyle(.white)
    }
}

#Preview {
    AppleSigninButton()
}
