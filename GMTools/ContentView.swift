//
//  ContentView.swift
//  GMTools
//
//  Created by Bobby Walker on 3/9/25.
//

import Supabase
import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated: Bool = false
    @AppStorage("profileFinished") var profileFinished: Bool?
    
    var body: some View {
        Group {
            if isAuthenticated {
                if profileFinished ?? false {
                    MainView()
                } else {
                    ProfileView()
                }
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
