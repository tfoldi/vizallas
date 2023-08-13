//
//  ContentView.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 18..
//

import SwiftUI

struct GaugingStationView: View {
    @StateObject private var gaugingStationsList: GaugingStationListModel = .init(data: [])
    @State private var searchText: String = ""
    @State private var isHomeActive = false
    @StateObject private var favorites = GaugingStationFavoritesModel()
    // Error handling
    @State private var errorMessage: String? = nil
    @State private var showingAlert = false

    var filteredResponse: GaugingStationListModel {
        if searchText.isEmpty {
            return gaugingStationsList
        } else {
            return GaugingStationListModel(data: gaugingStationsList.gaugingStations().filter {
                compareDiacriticInsensitive(base: $0.gaugingStation, searchText: searchText) ||
                    compareDiacriticInsensitive(base: $0.waterflow, searchText: searchText)
            })
        }
    }

    private func fetchData() async {
        do {
            try await gaugingStationsList.fetchData()
        } catch {
            errorMessage = "Failed to fetch data. Please try again later. (\(error))"
            showingAlert = true
            print("Fetching failed: \(error)")
        }
    }

    private var FavoriteStations: some View {
        ForEach(favorites.favorites, id: \.self) { favoriteId in
            if let item = filteredResponse.gaugingStations().first(where: { $0.id == favoriteId }) {
                GaugingStationCellView(item: item) {}
                    .background(
                        NavigationLink("", value: item)
                            .opacity(0)
                    )
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            favorites.remove(favorite: favoriteId)
                        } label: {
                            Label("Remove", systemImage: "star.slash.fill")
                        }
                    }

            } else {
                if searchText == "" {
                    Text("Loading data for \(favoriteId)")
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if gaugingStationsList.count == 0 {
                    ProgressView("Loading water levels").zIndex(1)
                }
                List {
                    Section(header: Text("Favorites")) {
                        if favorites.count == 0 && searchText == "" {
                            Text("No favorites yet. Swipe left to set a few.")
                                .italic()
                        } else {
                            FavoriteStations
                        }
                    }

                    ForEach(filteredResponse.sectionTitles, id: \.self) { section in
                        Section(header: Text(section)) {
                            ForEach(filteredResponse.items(for: section)) { item in
                                GaugingStationCellView(item: item, action: {})
                                    .background(
                                        NavigationLink("", value: item)
                                            .opacity(0)
                                    )
                                    .swipeActions(allowsFullSwipe: false) {
                                        Button {
                                            favorites.add(favorite: item.id)
                                        } label: {
                                            Label("Add", systemImage: "star.fill")
                                        }
                                        .tint(.green)
                                    }
                            }
                        }
                    }
                }
                .navigationDestination(for: GaugingStationModel.self) { item in
                    DetailsView(item: item)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationDestination(isPresented: $isHomeActive) {
                    HomeView()
                }

                .refreshable {
                    await fetchData()
                }
                .task {
                    if gaugingStationsList.count == 0 {
                        await fetchData()
                    } else {
                        print("there is already data in it")
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error fetching data from server"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("Close")))
                }
            }

            .searchable(text: $searchText)
            .navigationTitle("Gauging Stations")
        }
        .environmentObject(favorites)
    }
}

struct GaugingStationView_Previews: PreviewProvider {
    static var previews: some View {
        GaugingStationView()
    }
}
