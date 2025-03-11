//
//  ContentView.swift
//  GMTools
//
//  Created by Bobby Walker on 3/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated: Bool = false
    
    var body: some View {
        Group {
            if isAuthenticated {
                ProfileView()
            } else {
                AuthView()
            }
        }
        .task {
            for await state in supabase.auth.authStateChanges {
                if [.initialSession, .signedIn, .signedOut].contains(state.event) {
                    isAuthenticated = state.session != nil
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
