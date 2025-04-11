//
//  Theme.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//

// Theme.swift for InstaJam app-wide design constants
import SwiftUI

struct Theme {
    // Colors
    static let primaryAccent = Color("PrimaryAccent")
    static let softBackground = Color("SoftBackground")
    static let chipSelected = Color("ChipSelected")
    static let chipUnselected = Color("ChipUnselected")

    // Fonts
    static let headingFont = Font.system(size: 24, weight: .bold)
    static let subheadingFont = Font.system(size: 16, weight: .medium)
    static let bodyFont = Font.system(size: 14)

    // Spacing
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 12

    // Shadows
    static let cardShadow = Color.black.opacity(0.05)
    static let shadowRadius: CGFloat = 3
}
