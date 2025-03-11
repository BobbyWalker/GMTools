//
//  SignInWithGoogleViewModel.swift
//  GMTools
//
//  Created by Bobby Walker on 3/11/25.
//

import Foundation
import GoogleSignIn
import Supabase

struct GoogleSignInResult {
    let idToken: String
    let nonce: String?
}

class SignInWithGoogleViewModel {
    var nonce: String?
    
    func signIn(completion: @escaping (Result<GoogleSignInResult, Error>) -> Void) {
        guard let topViewController = UIApplication.getTopViewController() else {
            completion(.failure(NSError()))
            return
        }
        nonce = randomNonceString()
        GIDSignIn.sharedInstance.signIn(
            withPresenting: topViewController
        ) { signInResult, error in
            guard let result = signInResult, let idToken = result.user.idToken else {
                completion(.failure(NSError()))
                return
            }
            completion(.success(.init(idToken: idToken.tokenString, nonce: self.nonce)))
        }
    }
    
    func finishSignIn(idToken: String) async {
        let credentials = OpenIDConnectCredentials(
            provider: .google,
            idToken: idToken,
            nonce: nonce
        )
        do {
            try await supabase.auth.signInWithIdToken(credentials: credentials)
        } catch {
            print(error)
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate \(length) random bytes: \(errorCode)"
            )
        }
        
        let charset: [Character] = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
}
