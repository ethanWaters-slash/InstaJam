//
//  SignupView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    @Binding var path: NavigationPath
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack(spacing: Theme.padding) {
            Text("🎉 Create an Account")
                .font(Theme.headingFont)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button("Sign Up", action: signUp)
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty)
        }
        .padding()
        .background(Theme.softBackground)
        .navigationBarTitle("Sign Up", displayMode: .inline)
    }

    private func signUp() {
        errorMessage = nil

        AuthService.shared.signUp(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // ✅ Push to Profile Setup screen
                    path.append(AuthRoute.profileSetup)

                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
