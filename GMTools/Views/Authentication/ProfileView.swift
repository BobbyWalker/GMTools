//
//  ProfileView.swift
//  GMTools
//
//  Created by Bobby Walker on 3/9/25.
//

import PhotosUI
import Storage
import Supabase
import SwiftUI

struct ProfileView: View {
    @AppStorage("profileFinished") var profileFinished: Bool?
    @Bindable var viewModel = ProfileViewModel.shared
    
    @State var imageSelection: PhotosPickerItem?
    
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
                VStack {
                    Text("Setup your profile. We require a username and full name.  Other users will be able to see the Username, but not your full name or email address.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                    Section {
                        HStack {
                            Spacer()
                            Group {
                                if let avatarImage = viewModel.avatarImage {
                                    avatarImage.image
                                        .resizable()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundStyle(.secondary)
                                        .frame(width: 100, height: 100)
                                }
                            }
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 150, height: 150)
                            
                            PhotosPicker(selection: $imageSelection, matching: .images) {
                                Image(systemName: "pencil.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 30))
                                    .foregroundColor(.accentColor)
                            }
//                            .padding(.leading, -30)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 30)
                    
                    Section {
                        ProfileUsername()
                        TextField("Full Name", text: $viewModel.fullName)
                            .textContentType(.name)
                        TextField("Website", text: $viewModel.website)
                            .textContentType(.URL)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    
                    Section {
                        Button {
                            updateProfileButtonTapped()
                        } label: {
                            Text("Update Profile")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!viewModel.isProfileComplete)
                    }
                    .padding(.top, 50)
                    .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Sign Out", role: .destructive) {
                            Task {
                                try? await supabase.auth.signOut()
                                print("Signing Out...")
                            }
                        }
                    }
                })
            }
        }
        .onChange(of: imageSelection) { _, newValue in
            guard let newValue else { return }
            loadTransferrable(from: newValue)
        }
        .task {
            await viewModel.getInitialProfile()
        }
    }
    
    func updateProfileButtonTapped() {
        Task {
            let profileComplete = await viewModel.updateProfile()
            profileFinished = profileComplete
        }
    }
    
    private func loadTransferrable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                viewModel.avatarImage = try await imageSelection.loadTransferable(type: AvatarImage.self)
            } catch {
                debugPrint(error)
            }
        }
    }
}

#Preview {
    ProfileView()
}
