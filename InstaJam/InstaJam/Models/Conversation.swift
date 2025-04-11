//
//  Conversation.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/7/25.
//
import Foundation

struct Conversation: Identifiable {
    var id: String
    var otherUser: UserProfile
    var lastMessage: String
    var timestamp: Date
    var hasUnreadMessages: Bool // 👈 New field
}
