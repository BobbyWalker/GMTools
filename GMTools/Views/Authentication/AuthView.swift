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
    @AppStorage("signInMethod") private var signInMethod: String?
    
    var body: some View {
        ZStack {
            Image(.background)
            
            VStack {
                if signInMethod == "password" {
                    LoginView(method: $signInMethod)
                        .background(Color.white.opacity(0.0))
                } else {
                    LinkView(method: $signInMethod)
                        .background(Color.white.opacity(0.0))
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
