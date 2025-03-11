//
//  SignInWithGoogleViewModel.swift
//  GMTools
//
//  Created by Bobby Walker on 3/11/25.
//

import Foundation
import GoogleSignIn

struct GoogleSignInResult {
    let idToken: String
}

class SignInWithGoogleViewModel {
    func signIn(completion: @escaping (Result<GoogleSignInResult, Error>) -> Void) {
        guard let topViewController = UIApplication.getTopViewController() else {
            completion(.failure(NSError()))
            return
        }
        GIDSignIn.sharedInstance.signIn(
            withPresenting: topViewController
        ) { signInResult, error in
            guard let result = signInResult, let idToken = result.user.idToken else {
                completion(.failure(NSError()))
                return
            }
            completion(.success(.init(idToken: idToken.tokenString)))
        }
    }
}
