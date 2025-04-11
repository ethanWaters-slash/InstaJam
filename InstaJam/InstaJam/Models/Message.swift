//
//  Message.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/7/25.
//
import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    var id: String = UUID().uuidString
    var senderId: String
    var receiverId: String
    var text: String
    var timestamp: Date
    var participants: [String]
    var isRead: Bool = false // 👈 Add this
}
