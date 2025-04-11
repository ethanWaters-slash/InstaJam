//
//  LoginView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import SwiftUI
import FirebaseAuth

enum AuthRoute: Hashable {
    case profileSetup
    case matchList
    case mainTab
    case signup
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    @Binding var path: NavigationPath
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Theme.padding) {
                Text("🎶 Welcome to InstaJam")
                    .font(Theme.headingFont)
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if isLoading {
                    ProgressView("Logging in...")
                        .padding(.vertical)
                } else {
                    Button("Log In") {
                        logIn()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button("Sign Up") {
                    path.append(AuthRoute.signup)
                }
                .font(.footnote)
                .padding(.top, 4)
            }
            .padding()
            .background(Theme.softBackground)
            .navigationTitle("Login")
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .mainTab:
                    MainTabView(isLoggedIn: $isLoggedIn, path: $path)
                case .profileSetup:
                    ProfileSetupView(path: $path, isLoggedIn: $isLoggedIn)
                case .matchList:
                    MatchListView(path: $path, isLoggedIn: $isLoggedIn)
                case .signup:
                    SignupView(path: $path, isLoggedIn: $isLoggedIn)
                }
            }
        }
    }
    
    // MARK: - Auth Logic
    
    private func logIn() {
        isLoading = true
        errorMessage = nil
        
        AuthService.shared.signIn(email: email, password: password) { result in
            switch result {
            case .success:
                if let user = AuthService.shared.getCurrentUser() {
                    FirebaseService().fetchProfile(for: user.uid) { profile in
                        DispatchQueue.main.async {
                            isLoading = false
                            if profile != nil {
                                isLoggedIn = true
                            } else {
                                path.append(AuthRoute.profileSetup)
                            }
                        }
                    }
                } else {
                    isLoading = false
                    errorMessage = "Unexpected error: No current user."
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
