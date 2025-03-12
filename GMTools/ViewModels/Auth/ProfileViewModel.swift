//
//  ProfileViewModel.swift
//  GMTools
//
//  Created by Bobby Walker on 3/11/25.
//

import Foundation
import Supabase


@Observable
class ProfileViewModel {
    static let shared = ProfileViewModel()
    
    var username = ""
    var fullName = ""
    var website = ""
    var avatar = ""
    var isLoading = false
    
    var avatarImage: AvatarImage? = nil
    
    var isProfileComplete: Bool {
        !username.isEmpty && !fullName.isEmpty
    }
    
    var isUserNameValid: Bool {
        var valid = true
        if username.count < 3 && username.count > 20 {
            valid = false
        }
        
        for profile in profiles {
            if profile.username == username {
                valid = false
                break
            }
        }
        
        return valid
    }
    
    var profiles: [Profile] = []
    var fetchUserProfiles: Bool {
        didSet {
            if fetchUserProfiles {
                Task {
                    await fetchProfiles()
                }
            }
        }
    }
    
    init() {
        fetchUserProfiles = false
    }
    
    func getInitialProfile() async {
        do {
            let currentUser = try await supabase.auth.session.user
            
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            self.username = profile.username ?? ""
            self.fullName = profile.fullName ?? ""
            self.website = profile.website ?? ""
            
            if self.username.isEmpty {
                fetchUserProfiles = true
            }
            if let avatarUrl = profile.avatarURL, !avatarUrl.isEmpty {
                try await downloadImage(path: avatarUrl)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    private func downloadImage(path: String) async throws {
        let data = try await supabase.storage.from("avatars").download(path: path)
        avatarImage = AvatarImage(data: data)
    }
    
    private func fetchProfiles() async {
            print("Loading profiles...")
            do {
                let rawProfiles: [Profile] = try await supabase
                    .from("profiles")
                    .select("username")
                    .execute()
                    .value
                
                for profile in rawProfiles {
                    let username: String? = profile.username
                    if username == nil { continue }
                    let newProfile = Profile(username: username, fullName: nil, website: nil, avatarURL: nil)
                    profiles.append(newProfile)
                }
            } catch {
                print(error)
            }
    }
    
    func updateProfile() async -> Bool {
            isLoading = true
            defer { isLoading = false }
            do {
                let imageURL = try await uploadImage()
                
                let currentUser = try await supabase.auth.session.user
                
                let updatedProfile = Profile(
                    username: username,
                    fullName: fullName,
                    website: website,
                    avatarURL: imageURL
                )
                try await supabase
                    .from("profiles")
                    .update(updatedProfile)
                    .eq("id", value: currentUser.id)
                    .execute()
                
                return isProfileComplete
                
            } catch {
                debugPrint(error)
                return false
            }
        
    }
    
    private func uploadImage() async throws -> String? {
        guard let data = avatarImage?.data else { return nil }
        
        let filePath = "\(UUID().uuidString).jpeg"
        
        try await supabase.storage
            .from("avatars")
            .upload(
                filePath,
                data: data,
                options: FileOptions(contentType: "image/jpeg")
            )
        
        return filePath
    }
}
