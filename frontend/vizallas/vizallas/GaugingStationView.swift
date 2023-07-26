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

    var body: some View {
        NavigationStack {
            ZStack {
                if gaugingStationsList.count == 0 {
                    ProgressView("Loading water levels").zIndex(1)
                }
                List {
                    Section(header: Text("Favorites")) {
                        let favorites = ["Budapest-Duna", "Göd-Duna"]

                        if favorites.count == 0 {
                            Text("No favorites yet")
                        } else {
                            ForEach(favorites, id: \.self) { favoriteId in
                                if let item = gaugingStationsList.gaugingStations().first(where: { $0.id == favoriteId }) {
                                    GaugingStationCellView(item: item) {}
                                        .background(
                                            NavigationLink("", value: item)
                                                .opacity(0)
                                        )

                                } else {
                                    Text("Loading data for \(favoriteId)")
                                }
                            }
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
                            }
                        }
                    }
                }
                .navigationDestination(for: GaugingStationModel.self) { item in
                    DetailsView(item: item)
                }
                .listStyle(InsetGroupedListStyle())
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Home", action: {
                                isHomeActive = true // Activate the home view
                            })
                            Button("Select Favorites", action: {
                                // Perform an action for selecting favorites
                            })
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .navigationDestination(isPresented: $isHomeActive) {
                    HomeView()
                }

                .refreshable {
                    do {
                        try await gaugingStationsList.fetchData()
                    } catch {
                        print("Fetching failed")
                    }
                }
                .task {
                    if gaugingStationsList.count == 0 {
                        do {
                            try await gaugingStationsList.fetchData()
                        } catch {
                            print("Fetching failed")
                        }
                    } else {
                        print("there is already data in it")
                    }
                }
            }

            .searchable(text: $searchText)
            .navigationTitle("Gauging Stations")
        }
    }
}

struct GaugingStationView_Previews: PreviewProvider {
    static var previews: some View {
        GaugingStationView()
    }
}
