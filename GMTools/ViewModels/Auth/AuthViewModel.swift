//
//  AuthViewModel.swift
//  GMTools
//
//  Created by Bobby Walker on 3/10/25.
//

import Observation
import Supabase
import SwiftUI


@Observable
class AuthViewModel: NSObject, Identifiable {
    static let shared = AuthViewModel()
    static let apple = SignInWithAppleViewModel()
    static let google = SignInWithGoogleViewModel()
    
    var email = ""
    var password = ""
    var isLoading = false
    var authResult: Result<Void, Error>? {
        didSet {
            if case .failure = authResult {
                showAlert = true
            }
        }
    }
    
    var showAlert: Bool = false
    var errorMessage: String?
    
    func toggleLoadingState() {
        withAnimation {
            isLoading.toggle()
        }
    }
    
    @MainActor
    func signIn() async {
        toggleLoadingState()
        defer { toggleLoadingState() }
        
        do {
            try await supabase.auth.signIn(email: email, password: password)
            authResult = .success(())
        } catch {
            authResult = .failure(error)
            errorMessage = error.localizedDescription
        }
    }
}


