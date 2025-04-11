//
//  ProfileViewModel.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import Foundation

class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var selectedInstruments: [String] = []
    @Published var selectedGenres: [String] = []
    @Published var skillLevel: String = ""
    @Published var bio: String = ""

    func saveProfile(completion: @escaping () -> Void) {
        guard let currentUserId = AuthService.shared.getCurrentUser()?.uid else { return }

        let profile = UserProfile(
            userId: currentUserId,
            name: name,
            instruments: selectedInstruments,
            genres: selectedGenres,
            skillLevel: skillLevel,
            bio: bio
        )

        FirebaseService().saveProfile(profile) { error in
            if let error = error {
                print("❌ Failed to save profile: \(error.localizedDescription)")
            } else {
                print("✅ Profile saved")
            }
            completion()
        }
    }
}
