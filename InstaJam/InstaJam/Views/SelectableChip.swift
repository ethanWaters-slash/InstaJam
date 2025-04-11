//
//  SelectableChip.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/4/25.
//
import SwiftUI

struct SelectableChip: View {
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
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(isSelected ? Theme.primaryAccent : .gray.opacity(0.3), lineWidth: 1)
            )
            .onTapGesture {
                action()
            }
    }
}
