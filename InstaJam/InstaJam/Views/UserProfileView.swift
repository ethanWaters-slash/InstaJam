//
//  UserProfileView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/6/25.
//
import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    @State private var profile: UserProfile?
    @State private var isLoading = true
    @State private var isSaving = false
    @Binding var path: NavigationPath
    @Binding var isLoggedIn: Bool
    @State private var showValidationAlert = false

    private let firebaseService = FirebaseService()
    private let instruments = ["Guitar", "Drums", "Bass", "Vocals", "Piano"]
    private let genres = ["Rock", "Jazz", "Hip-Hop", "Classical", "Pop"]
    private let skillLevels = ["Beginner", "Intermediate", "Advanced"]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.softBackground.ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 0) {
                        TabHeaderView(title: "InstaJam", subtitle: "Your Profile")
                        Spacer()
                        ProgressView("Loading profile...")
                        Spacer()
                    }
                } else if let profile = profile {
                    VStack(spacing: 0) {
                        TabHeaderView(title: "InstaJam", subtitle: "Your Profile")

                        ScrollView {
                            VStack(spacing: Theme.padding) {
                                TextField("Your name", text: binding(for: \.name))
                                    .textFieldStyle(.roundedBorder)

                                VStack(alignment: .leading) {
                                    Text("Instruments").font(.headline)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(instruments, id: \.self) { instrument in
                                                FilterChip(
                                                    label: instrument,
                                                    isSelected: profile.instruments.contains(instrument)
                                                ) {
                                                    toggleSelection(instrument, in: &self.profile!.instruments)
                                                }
                                            }
                                        }
                                    }
                                }

                                VStack(alignment: .leading) {
                                    Text("Genres").font(.headline)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(genres, id: \.self) { genre in
                                                FilterChip(
                                                    label: genre,
                                                    isSelected: profile.genres.contains(genre)
                                                ) {
                                                    toggleSelection(genre, in: &self.profile!.genres)
                                                }
                                            }
                                        }
                                    }
                                }

                                VStack(alignment: .leading) {
                                    Text("Skill Level").font(.headline)
                                    Picker("Skill Level", selection: binding(for: \.skillLevel)) {
                                        ForEach(skillLevels, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }

                                VStack(alignment: .leading) {
                                    Text("Bio").font(.headline)
                                    TextEditor(text: binding(for: \.bio))
                                        .frame(height: 100)
                                        .background(Color.white)
                                        .cornerRadius(Theme.cornerRadius)
                                }

                                Button(action: saveProfile) {
                                    if isSaving {
                                        ProgressView()
                                    } else {
                                        Text("Save Profile")
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Theme.primaryAccent)
                                            .cornerRadius(Theme.cornerRadius)
                                    }
                                }

                                Button("Log Out") {
                                    do {
                                        try AuthService.shared.signOut()
                                        isLoggedIn = false
                                    } catch {
                                        print("❌ Log out failed: \(error.localizedDescription)")
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top, Theme.padding)
                            }
                            .padding()
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        TabHeaderView(title: "InstaJam", subtitle: "Your Profile")

                        Spacer()
                        Text("No profile found.")
                            .foregroundColor(.secondary)

                        Button("Create Profile") {
                            path.append(AuthRoute.profileSetup)
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .alert("Please complete all required fields.", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear(perform: loadProfile)
        }
    }

    private func toggleSelection(_ item: String, in array: inout [String]) {
        if array.contains(item) {
            array.removeAll { $0 == item }
        } else {
            array.append(item)
        }
    }

    private func binding(for keyPath: WritableKeyPath<UserProfile, String>) -> Binding<String> {
        Binding<String>(
            get: { profile?[keyPath: keyPath] ?? "" },
            set: { profile?[keyPath: keyPath] = $0 }
        )
    }

    private func saveProfile() {
        guard let profile = profile,
              !profile.name.trimmingCharacters(in: .whitespaces).isEmpty,
              !profile.instruments.isEmpty,
              !profile.genres.isEmpty,
              !profile.skillLevel.isEmpty else {
            showValidationAlert = true
            return
        }

        isSaving = true
        firebaseService.saveProfile(profile) { error in
            DispatchQueue.main.async {
                isSaving = false
                if let error = error {
                    print("❌ Failed to save profile: \(error.localizedDescription)")
                }
            }
        }
    }

    private func loadProfile() {
        guard let user = AuthService.shared.getCurrentUser() else {
            isLoading = false
            return
        }

        firebaseService.fetchProfile(for: user.uid) { loadedProfile in
            DispatchQueue.main.async {
                self.profile = loadedProfile
                self.isLoading = false
            }
        }
    }
}
