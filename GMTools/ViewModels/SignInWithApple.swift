//
//  SignInWithApple.swift
//  GMTools
//
//  Created by Bobby Walker on 3/11/25.
//

import AuthenticationServices
import CryptoKit
import Foundation
import Supabase
import SwiftUI

struct SigninWithAppleResult {
    let idToken: String
    let nonce: String
}

class SignInWithAppleViewModel: NSObject {
    private var completionHandler: ((Result<SigninWithAppleResult, Error>) -> Void)?
    
    fileprivate var currentNonce: String?
    
    @MainActor
    func signInWithApple(idToken: String, nonce: String? = nil) async {
        AuthViewModel.shared.toggleLoadingState()
        defer { AuthViewModel.shared.toggleLoadingState() }
        
        do {
            let credentials = OpenIDConnectCredentials(provider: .apple, idToken: idToken, nonce: nonce)
            print("result: \(credentials)")
            let result = try await supabase.auth.signInWithIdToken(credentials: credentials)
            print("result: \(result)")
            AuthViewModel.shared.authResult = .success(())
        } catch {
            AuthViewModel.shared.authResult = .failure(error)
            AuthViewModel.shared.errorMessage = error.localizedDescription
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
    
    @available(iOS 13.0, *)
    func startSignInWithAppleFlow(completion: @escaping (Result<SigninWithAppleResult, Error>) -> Void) {
        guard let topViewController = UIApplication.getTopViewController() else {
            completion(.failure(NSError()))
            return
        }
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topViewController
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension SignInWithAppleViewModel: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return ASPresentationAnchor(frame: UIScreen.main.bounds)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce, let completion = completionHandler else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetch identity token")
            completion(.failure(NSError()))
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(NSError()))
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }
          
          let appleResult = SigninWithAppleResult(idToken: idTokenString, nonce: nonce)
          completion(.success(appleResult))
      }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // Handle error.
      print("Sign in with Apple errored: \(error)")
    }
}

extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene}).compactMap({ $0?.windows.first }).first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        
        return base
    }
}

extension UIViewController: @retroactive ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
