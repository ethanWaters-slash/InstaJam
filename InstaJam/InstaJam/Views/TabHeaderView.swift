//
//  TabHeaderView.swift
//  InstaJam
//
//  Created by Ethan Waters on 4/9/25.
//

import SwiftUI

struct TabHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.headline)
                .foregroundColor(.gray)

            Divider()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 16)
        .padding(.horizontal)
    }
}
