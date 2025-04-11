//
//  ContentView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import SwiftUI
import FirebaseAuth

struct ProfileSetupView: View {
    @Binding var path: NavigationPath
    @Binding var isLoggedIn: Bool
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showValidationAlert = false
    @State private var isSaving = false

    let instruments = ["Guitar", "Drums", "Bass", "Vocals", "Piano"]
    let genres = ["Rock", "Jazz", "Hip-Hop", "Classical", "Pop"]
    let skillLevels = ["Beginner", "Intermediate", "Advanced"]

    var body: some View {
        ZStack {
            Theme.softBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.padding) {
                    // Avatar-style header
                    VStack(spacing: 8) {
                        Text("Create Your Profile")
                            .font(Theme.headingFont)
                    }

                    // All input fields
                    VStack(spacing: Theme.padding) {
                        TextField("Your name", text: $viewModel.name)
                            .textFieldStyle(.roundedBorder)

                        VStack(alignment: .leading) {
                            Text("Instruments").font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(instruments, id: \.self) { instrument in
                                        FilterChip(
                                            label: instrument,
                                            isSelected: viewModel.selectedInstruments.contains(instrument)
                                        ) {
                                            toggleSelection(of: instrument, in: &viewModel.selectedInstruments)
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading) {
                            Text("Genres").font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(genres, id: \.self) { genre in
                                        FilterChip(
                                            label: genre,
                                            isSelected: viewModel.selectedGenres.contains(genre)
                                        ) {
                                            toggleSelection(of: genre, in: &viewModel.selectedGenres)
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading) {
                            Text("Skill Level").font(.headline)
                            Picker("Skill Level", selection: $viewModel.skillLevel) {
                                ForEach(skillLevels, id: \.self) { level in
                                    Text(level)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        VStack(alignment: .leading) {
                            Text("Bio").font(.headline)
                            TextEditor(text: $viewModel.bio)
                                .frame(height: 100)
                                .background(Color.white)
                                .cornerRadius(10)
                        }

                        Button(action: saveProfile) {
                            if isSaving {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Save Profile")
                                    .font(Theme.bodyFont.bold())
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.primaryAccent)
                                    .cornerRadius(Theme.cornerRadius)
                            }
                        }
                        .padding(.top)
                    }
                }
                .padding()
            }
        }
        .alert("Please complete all required fields (Name, Instruments, Genres, Skill Level).",
               isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    private func saveProfile() {
        guard !viewModel.name.trimmingCharacters(in: .whitespaces).isEmpty,
              !viewModel.selectedInstruments.isEmpty,
              !viewModel.selectedGenres.isEmpty,
              !viewModel.skillLevel.isEmpty else {
            showValidationAlert = true
            return
        }

        isSaving = true
        viewModel.saveProfile {
            DispatchQueue.main.async {
                isSaving = false
                isLoggedIn = true  // ✅ Mark user as logged in
                path = NavigationPath()  // ✅ Reset stack
            }
        }
    }
    private func toggleSelection(of item: String, in array: inout [String]) {
        if array.contains(item) {
            array.removeAll { $0 == item }
        } else {
            array.append(item)
        }
    }
}
