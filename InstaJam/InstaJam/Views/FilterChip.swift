//
//  FilterChip.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import SwiftUI
struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(label)
            .font(Theme.bodyFont)
            .padding(.horizontal, Theme.padding + 2)
            .padding(.vertical, Theme.padding / 2)
            .background(isSelected ? Theme.primaryAccent : .white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: isSelected ? Theme.primaryAccent.opacity(0.3) : .clear, radius: 2, x: 0, y: 2)
            .onTapGesture {
                action()
            }
    }
}
