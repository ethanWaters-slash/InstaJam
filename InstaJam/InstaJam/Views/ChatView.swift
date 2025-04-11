//
//  ChatView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/7/25.
//
//
//  ChatView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/7/25.
//

import SwiftUI
import FirebaseFirestore

struct ChatView: View {
    let currentUserId: String
    let otherUser: UserProfile

    @State private var messages: [Message] = []
    @State private var messageText = ""
    @State private var isLoading = true
    @State private var listener: ListenerRegistration?
    @State private var isOtherUserTyping = false
    @State private var typingListener: ListenerRegistration?

    private let firebaseService = FirebaseService()

    var body: some View {
        VStack {
            messagesListView

            Divider()

            messageInputBar
        }
        .navigationTitle(otherUser.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.softBackground.ignoresSafeArea())
        .onAppear {
            loadMessages()
            observeTyping()
        }
        .onDisappear {
            listener?.remove()
            typingListener?.remove()
            sendTypingStatus(isTyping: false)
        }
    }

    // MARK: - Messages List View

    private var messagesListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message, currentUserId: currentUserId)
                    }
                }
                .padding(.top)
            }
            .onChange(of: messages.count) { _ in
                scrollToBottom(with: proxy)
            }
        }
    }

    // MARK: - Message Input Bar

    private var messageInputBar: some View {
        HStack(spacing: 12) {
            TextField("Message...", text: $messageText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)

            Button("Send") {
                sendMessage()
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .foregroundColor(messageText.isEmpty ? .gray : Theme.primaryAccent)
        }
        .padding()
        .background(Color.white)
    }

    // MARK: - Message Handling

    private func loadMessages() {
        isLoading = true
        listener = firebaseService.observeMessages(
            between: currentUserId,
            and: otherUser.userId
        ) { newMessages in
            self.messages = newMessages
            self.isLoading = false
        }
    }

    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let newMessage = Message(
            senderId: currentUserId,
            receiverId: otherUser.userId,
            text: trimmedText,
            timestamp: Date(),
            participants: [currentUserId, otherUser.userId]
        )

        firebaseService.sendMessage(newMessage) { error in
            if let error = error {
                print("❌ Failed to send message: \(error.localizedDescription)")
            } else {
                messageText = ""
            }
        }
    }

    private func scrollToBottom(with proxy: ScrollViewProxy) {
        if let last = messages.last {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Typing Indicator

    private func observeTyping() {
        typingListener = firebaseService.observeTypingStatus(
            from: otherUser.userId,
            to: currentUserId
        ) { isTyping in
            self.isOtherUserTyping = isTyping
        }
    }

    private func sendTypingStatus(isTyping: Bool) {
        firebaseService.updateTypingStatus(
            from: currentUserId,
            to: otherUser.userId,
            isTyping: isTyping
        )
    }
}

// MARK: - Message Bubble View

private struct MessageBubble: View {
    let message: Message
    let currentUserId: String

    var isCurrentUser: Bool {
        message.senderId == currentUserId
    }

    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if isCurrentUser { Spacer() }

                Text(message.text)
                    .padding(12)
                    .background(isCurrentUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(16)
                    .frame(maxWidth: 260, alignment: isCurrentUser ? .trailing : .leading)

                if !isCurrentUser { Spacer() }
            }
        }
        .padding(.horizontal)
        .id(message.id)
    }
}
