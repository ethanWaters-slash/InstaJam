//
//  ProfileDetailView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import SwiftUI

struct ProfileDetailView: View {
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Avatar & Name
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)

                    Text(profile.name)
                        .font(.largeTitle.bold())
                }

                // Instruments
                InfoCard(icon: "guitars", title: "Instruments", content: profile.instruments.joined(separator: ", "))

                // Genres
                InfoCard(icon: "music.note", title: "Genres", content: profile.genres.joined(separator: ", "))

                // Skill Level
                InfoCard(icon: "star.fill", title: "Skill Level", content: profile.skillLevel)

                // Bio
                InfoCard(icon: "text.alignleft", title: "Bio", content: profile.bio)

                // ✅ Message Button
                if let currentUserId = AuthService.shared.getCurrentUser()?.uid {
                    NavigationLink(destination: ChatView(currentUserId: currentUserId, otherUser: profile)) {
                        Text("Message")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primaryAccent)
                            .foregroundColor(.white)
                            .cornerRadius(Theme.cornerRadius)
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .background(Theme.softBackground.ignoresSafeArea())
        .navigationTitle("Profile")
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)

            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
