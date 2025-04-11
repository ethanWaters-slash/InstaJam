//
//  MainTabView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/6/25.
//
import SwiftUI

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    @Binding var path: NavigationPath

    var body: some View {
        TabView {
            NavigationStack(path: $path) {
                MatchListView(path: $path, isLoggedIn: $isLoggedIn)
                    .navigationTitle("InstaJam")
                    .navigationBarTitleDisplayMode(.inline) // 👈 Keeps title in view
                    .navigationDestination(for: AuthRoute.self) { route in
                        routeView(for: route)
                    }
            }
            .tabItem {
                Label("Discover", systemImage: "music.note.list")
            }

            NavigationStack(path: $path) {
                UserProfileView(path: $path, isLoggedIn: $isLoggedIn)
                    .navigationTitle("InstaJam")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: AuthRoute.self) { route in
                        routeView(for: route)
                    }
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }

            NavigationStack(path: $path) {
                MessagingListView(currentUserId: AuthService.shared.getCurrentUser()?.uid ?? "", path: $path)
                    .navigationTitle("InstaJam")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: AuthRoute.self) { route in
                        routeView(for: route)
                    }
            }
            .tabItem {
                Label("Messages", systemImage: "bubble.left.and.bubble.right.fill")
            }
        }
        .accentColor(Theme.primaryAccent)
    }

    @ViewBuilder
    private func routeView(for route: AuthRoute) -> some View {
        switch route {
        case .profileSetup:
            ProfileSetupView(path: $path, isLoggedIn: $isLoggedIn)
        case .matchList:
            MatchListView(path: $path, isLoggedIn: $isLoggedIn)
        case .mainTab:
            MainTabView(isLoggedIn: $isLoggedIn, path: $path)
        case .signup:
            SignupView(path: $path, isLoggedIn: $isLoggedIn)
        }
    }
}
