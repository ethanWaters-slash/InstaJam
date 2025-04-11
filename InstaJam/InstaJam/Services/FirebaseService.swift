//
//  FirebaseService.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth

class FirebaseService {
    private let db = Firestore.firestore()
    private let collection = "profiles"

    // ✅ Save a user profile
    func saveProfile(_ profile: UserProfile, completion: @escaping (Error?) -> Void) {
        do {
            let documentId = profile.userId // userId should be their Firebase UID
            try db.collection("profiles").document(documentId).setData(from: profile)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    // ✅ Fetch a specific user's profile
    func fetchProfile(for userId: String, completion: @escaping (UserProfile?) -> Void) {
        db.collection(collection).document(userId).getDocument { snapshot, error in
            if let doc = snapshot, doc.exists {
                do {
                    let profile = try doc.data(as: UserProfile.self)
                    completion(profile)
                } catch {
                    print("❌ Failed to decode profile: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    // ✅ Fetch all profiles for matching
    func fetchProfiles(completion: @escaping ([UserProfile]?, Error?) -> Void) {
        db.collection(collection).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                let profiles = snapshot?.documents.compactMap {
                    try? $0.data(as: UserProfile.self)
                } ?? []
                completion(profiles, nil)
            }
        }
    }

    // ✅ Fetch conversations for the current user
    func fetchConversations(for userId: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        db.collection("messages")
            .whereField("participants", arrayContains: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Firestore query failed: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let docs = snapshot?.documents else {
                    print("⚠️ No documents returned")
                    completion(.success([]))
                    return
                }

                print("📨 Found \(docs.count) documents for user \(userId)")

                var latestMessagesByUser: [String: Conversation] = [:]
                let group = DispatchGroup()

                for doc in docs {
                    let data = doc.data()

                    let convoId = doc.documentID
                    let senderId = data["senderId"] as? String ?? ""
                    let receiverId = data["receiverId"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let isRead = data["isRead"] as? Bool ?? true

                    let otherUserId = senderId == userId ? receiverId : senderId
                    let isUnread = receiverId == userId && !isRead

                    group.enter()
                    self.fetchProfile(for: otherUserId) { profile in
                        defer { group.leave() }

                        guard let otherProfile = profile else {
                            print("⚠️ Could not fetch profile for \(otherUserId)")
                            return
                        }

                        let convo = Conversation(
                            id: convoId,
                            otherUser: otherProfile,
                            lastMessage: text,
                            timestamp: timestamp,
                            hasUnreadMessages: isUnread
                        )

                        // Keep only most recent message per user
                        if let existing = latestMessagesByUser[otherUserId] {
                            if timestamp > existing.timestamp {
                                latestMessagesByUser[otherUserId] = convo
                            }
                        } else {
                            latestMessagesByUser[otherUserId] = convo
                        }
                    }
                }

                group.notify(queue: .main) {
                    let sortedConvos = latestMessagesByUser.values.sorted { $0.timestamp > $1.timestamp }
                    print("✅ Finished assembling \(sortedConvos.count) unique conversations")
                    completion(.success(sortedConvos))
                }
            }
    }


    func sendMessage(_ message: Message, completion: @escaping (Error?) -> Void) {
        var data: [String: Any]
        
        do {
            data = try Firestore.Encoder().encode(message)
            // Add participants array if not included in model
            data["participants"] = [message.senderId, message.receiverId]
        } catch {
            completion(error)
            return
        }

        db.collection("messages").addDocument(data: data, completion: completion)
    }
    // ✅ Mark messages as read
    func markMessagesAsRead(from senderId: String, to receiverId: String) {
        db.collection("messages")
            .whereField("senderId", isEqualTo: senderId)
            .whereField("receiverId", isEqualTo: receiverId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching unread messages: \(error.localizedDescription)")
                    return
                }

                let batch = self.db.batch()

                snapshot?.documents.forEach { doc in
                    batch.updateData(["isRead": true], forDocument: doc.reference)
                }

                batch.commit { batchError in
                    if let batchError = batchError {
                        print("❌ Error marking messages as read: \(batchError.localizedDescription)")
                    } else {
                        print("✅ Messages marked as read.")
                    }
                }
            }
    }


    @discardableResult
    func observeConversations(for userId: String, completion: @escaping ([Conversation]) -> Void) -> ListenerRegistration {
        return db.collection("messages")
            .whereField("participants", arrayContains: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else {
                    print("❌ Failed to observe conversations: \(error?.localizedDescription ?? "Unknown error")")
                    completion([])
                    return
                }

                var latestMessagesByUser: [String: Conversation] = [:]
                let group = DispatchGroup()

                for doc in docs {
                    let data = doc.data()
                    let senderId = data["senderId"] as? String ?? ""
                    let receiverId = data["receiverId"] as? String ?? ""
                    let text = data["text"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let otherUserId = senderId == userId ? receiverId : senderId
                    let isUnread = receiverId == userId && !(data["read"] as? Bool ?? true)

                    group.enter()
                    self.fetchProfile(for: otherUserId) { profile in
                        defer { group.leave() }

                        guard let otherProfile = profile else { return }

                        let convo = Conversation(
                            id: doc.documentID,
                            otherUser: otherProfile,
                            lastMessage: text,
                            timestamp: timestamp,
                            hasUnreadMessages: isUnread
                        )

                        if let existing = latestMessagesByUser[otherUserId] {
                            if timestamp > existing.timestamp {
                                latestMessagesByUser[otherUserId] = convo
                            }
                        } else {
                            latestMessagesByUser[otherUserId] = convo
                        }
                    }
                }

                group.notify(queue: .main) {
                    let sortedConvos = latestMessagesByUser.values.sorted { $0.timestamp > $1.timestamp }
                    completion(sortedConvos)
                }
            }
    }

    @discardableResult
    func observeMessages(between userId1: String, and userId2: String, completion: @escaping ([Message]) -> Void) -> ListenerRegistration {
        return db.collection("messages")
            .whereField("participants", arrayContains: userId1)
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("❌ Failed to observe messages: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                let messages = documents.compactMap {
                    try? $0.data(as: Message.self)
                }.filter {
                    ($0.senderId == userId1 && $0.receiverId == userId2) ||
                    ($0.senderId == userId2 && $0.receiverId == userId1)
                }

                completion(messages)
            }
    }
    func updateTypingStatus(from userId: String, to receiverId: String, isTyping: Bool) {
        let docId = "\(userId)_\(receiverId)"
        db.collection("typingStatus").document(docId).setData([
            "isTyping": isTyping,
            "timestamp": FieldValue.serverTimestamp()
        ])
    }

    @discardableResult
    func observeTypingStatus(from otherUserId: String, to currentUserId: String, completion: @escaping (Bool) -> Void) -> ListenerRegistration {
        let docId = "\(otherUserId)_\(currentUserId)"
        return db.collection("typingStatus").document(docId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Typing status observation failed: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let data = snapshot?.data() else {
                    // Document might not exist yet — treat as not typing
                    completion(false)
                    return
                }

                let isTyping = data["isTyping"] as? Bool ?? false
                completion(isTyping)
            }
    }
}

class AuthService {
    static let shared = AuthService()
    private init() {}

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}
