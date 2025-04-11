//
//  MatchListView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import SwiftUI

struct MatchListView: View {
    @Binding var path: NavigationPath
    @Binding var isLoggedIn: Bool

    @State private var profiles: [UserProfile] = []
    @State private var isLoading = true
    @State private var selectedInstrument: String? = nil
    @State private var selectedGenre: String? = nil

    private let firebaseService = FirebaseService()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                // Fixed-height header with consistent spacing
                TabHeaderView(title: "InstaJam", subtitle: "Find Musicians Near You")

                // Ensures mainContent fills remaining space and avoids shifting
                mainContent
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(edges: .bottom) // Allows full use of vertical space under TabBar
            .navigationBarHidden(true)
            .navigationDestination(for: AuthRoute.self) { route in
                routeView(for: route)
            }
            .onAppear(perform: loadProfiles)
        }
    }

    private var mainContent: some View {
        ZStack {
            Theme.softBackground.ignoresSafeArea()

            VStack(spacing: Theme.padding) {
                instrumentFilters
                genreFilters

                if isLoading {
                    loadingView
                } else if filteredProfiles.isEmpty {
                    emptyState
                } else {
                    profileList
                }
            }
        }
    }

    // MARK: - Filter UI

    private var instrumentFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["Guitar", "Drums", "Vocals", "Bass", "Piano"], id: \.self) { instrument in
                    FilterChip(
                        label: instrument,
                        isSelected: selectedInstrument == instrument
                    ) {
                        selectedInstrument = selectedInstrument == instrument ? nil : instrument
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private var genreFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(["Rock", "Jazz", "Pop", "Hip-Hop", "Classical"], id: \.self) { genre in
                    FilterChip(
                        label: genre,
                        isSelected: selectedGenre == genre
                    ) {
                        selectedGenre = selectedGenre == genre ? nil : genre
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
    }

    // MARK: - UI States

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("🎧 Finding musicians near you...")
                .padding()
            Spacer()
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("😕 No matching musicians.")
                .foregroundColor(.secondary)
                .padding()
            Spacer()
        }
    }

    private var profileList: some View {
        List(filteredProfiles) { profile in
            NavigationLink(destination: ProfileDetailView(profile: profile)) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.name)
                        .font(Theme.subheadingFont)
                        .foregroundColor(.primary)

                    Text("\(emojiForInstrument(profile.instruments.first ?? "")) \(profile.instruments.joined(separator: ", "))")

                    Text("🎶 \(profile.genres.joined(separator: ", "))")
                        .font(Theme.bodyFont)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Color.white)
                        .shadow(color: Theme.cardShadow, radius: Theme.shadowRadius, x: 0, y: 2)
                )
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .padding(.bottom, 80) // 👈 Add this
    }
    // MARK: - Logic
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

    private var filteredProfiles: [UserProfile] {
        guard let currentUserId = AuthService.shared.getCurrentUser()?.uid else { return [] }

        return profiles.filter { profile in
            let isNotCurrentUser = profile.userId != currentUserId
            let matchesInstrument = selectedInstrument == nil || profile.instruments.contains(selectedInstrument!)
            let matchesGenre = selectedGenre == nil || profile.genres.contains(selectedGenre!)
            return isNotCurrentUser && matchesInstrument && matchesGenre
        }
    }
    private func loadProfiles() {
        firebaseService.fetchProfiles { fetchedProfiles, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error loading profiles: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                profiles = fetchedProfiles ?? []
                isLoading = false
            }
        }
    }
    func emojiForInstrument(_ instrument: String) -> String {
        switch instrument.lowercased() {
        case "guitar":
            return "🎸"
        case "drums":
            return "🥁"
        case "bass":
            return "🎸"
        case "vocals":
            return "🎤"
        case "piano":
            return "🎹"
        default:
            return "🎵"
        }
    }
}
