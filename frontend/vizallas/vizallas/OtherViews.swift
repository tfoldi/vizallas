//
//  File.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 19..
//

import SwiftUI

struct FavoriteButton: View {
    @State private var isFavorite: Bool
    private let action: () -> Void

    init(isFavorite: Bool, action: @escaping () -> Void) {
        _isFavorite = State(initialValue: isFavorite)
        self.action = action
    }

    var body: some View {
        Button(action: {
            isFavorite.toggle()
            action()
        }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .yellow : .gray)
        }
    }
}

struct HomeView: View {
    var body: some View {
        Text("Home View")
            .navigationTitle("Home")
    }
}

struct DetailsView: View {
    let item: GaugingStationModel

    var body: some View {
        Text("Details View for \(item.gaugingStation)")
            .navigationTitle("Details")
    }
}
