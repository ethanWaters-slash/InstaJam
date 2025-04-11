//
//  RootView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/6/25.
//
import SwiftUI

struct RootView: View {
    @Binding var isLoggedIn: Bool
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if isLoggedIn {
                    MainTabView(isLoggedIn: $isLoggedIn, path: $path)
                        .onAppear {
                        }
                } else {
                    LoginView(path: $path, isLoggedIn: $isLoggedIn)
                }
            }
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
}
