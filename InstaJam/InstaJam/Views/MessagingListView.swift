//
//  MessagingListView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/7/25.
//
import SwiftUI
import FirebaseFirestore

struct MessagingListView: View {
    let currentUserId: String
    @Binding var path: NavigationPath

    @State private var conversations: [Conversation] = []
    @State private var isLoading = true
    @State private var convoListener: ListenerRegistration?

    private let firebaseService = FirebaseService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Fixed header at top
                TabHeaderView(title: "InstaJam", subtitle: "Messages")

                // Fill remaining vertical space with message content
                Group {
                    if isLoading {
                        ProgressView("Loading conversations...")
                            .frame(maxHeight: .infinity)
                            .padding()
                    } else if conversations.isEmpty {
                        Spacer()
                        Text("No messages yet.")
                            .foregroundColor(.gray)
                            .font(.body)
                        Spacer()
                    } else {
                        List(conversations) { convo in
                            NavigationLink {
                                ChatView(currentUserId: currentUserId, otherUser: convo.otherUser)
                                    .onAppear {
                                        firebaseService.markMessagesAsRead(
                                            from: convo.otherUser.userId,
                                            to: currentUserId
                                        )
                                    }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(convo.otherUser.name)
                                            .font(.headline)

                                        Text(convo.lastMessage)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(convo.timestamp, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.gray)

                                        if convo.hasUnreadMessages {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .padding(.bottom, 80) // 👈 Add this line
}
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
            .onAppear {
                startListeningForConversations()
            }
            .onDisappear {
                convoListener?.remove()
            }
        }
    }
    // 🔁 Real-time listener
    private func startListeningForConversations() {
        isLoading = true
        convoListener = firebaseService.observeConversations(for: currentUserId) { updatedConvos in
            self.conversations = updatedConvos
            self.isLoading = false
        }
    }
}
