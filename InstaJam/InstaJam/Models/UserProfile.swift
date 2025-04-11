//
//  UserProfile.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import Foundation
import FirebaseFirestore

struct UserProfile: Codable, Identifiable {
    var id: String { userId } // 👈 ensure this is non-optional
    let userId: String       // 👈 make sure this is never optional!
    var name: String
    var instruments: [String]
    var genres: [String]
    var skillLevel: String
    var bio: String
}
