//
//  ProfileUsername.swift
//  GMTools
//
//  Created by Bobby Walker on 3/11/25.
//

import SwiftUI

struct ProfileUsername: View {
    @Bindable var viewModel = ProfileViewModel.shared
    
    let profileNames = ProfileViewModel.shared.profiles
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.username.isEmpty ? "Username is required" :"Username is already taken.")
                .font(.caption)
                .foregroundColor(.red)
                .fontWeight(.bold)
                .opacity(viewModel.isUserNameValid ? 0 : 1)
            
            TextField("Username", text: $viewModel.username)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .foregroundColor(viewModel.isUserNameValid ? .primary : .red)
                .bold(!viewModel.isUserNameValid)
        }
            
    }
}

#Preview {
    ProfileView()
}
