//
//  LoginView.swift
//  GMTools
//
//  Created by Bobby Walker on 3/10/25.
//

import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel = .shared

    @Binding var method: String?

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
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "person.badge.key")
                            .padding(.trailing)
                        Text("Login With Email & Password")
                    }
                    .frame(maxWidth: .infinity)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Email", systemImage: "envelope")
                            .font(.headline)
                        TextField("Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .textContentType(.emailAddress)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Password", systemImage: "key")
                            .font(.headline)
                        SecureField("Password", text: $viewModel.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .textContentType(.password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.signIn()
                        }
                    }, label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(width: 75, height: 75)
                                .tint(.white)
                        } else {
                            Text("Login")
                                .font(.headline)
                                .padding()
                        }
                    })
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background((viewModel.email.isEmpty || viewModel.password.isEmpty) ? Color.gray : Color.blue)
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
                    
                    Button {
                        withAnimation {
                            method = nil
                        }
                    } label: {
                        Text("Choose another method to login")
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .padding()
                .alert(isPresented: $viewModel.showAlert, content: {
                    Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("Try Again")))
                })
                .navigationTitle(Text("GM Tools"))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    LoginView(method: .constant("password"))
}
