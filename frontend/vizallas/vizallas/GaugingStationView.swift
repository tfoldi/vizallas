//
//  ContentView.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 18..
//

import SwiftUI

struct GaugingStationView: View {
    @State private var gaugingStationsList: GaugingStationListModel = .init(data: [])
    @State private var searchText: String = ""
    @State private var isHomeActive = false
    @State private var isDetailActive = false
    @State private var selectedGaugingStation: GaugingStationModel?

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
                        Text("No favorites yet")
                    
                    }
    
                    ForEach(filteredResponse.sectionTitles, id: \.self) { section in
                        Section(header: Text(section)) {
                            ForEach(filteredResponse.items(for: section)) { item in
                                GaugingStationCellView(item: item, action: {
                                    selectedGaugingStation = item
                                    isDetailActive = true
                                })
                            }
                        }
                    }
                }.navigationDestination(isPresented: $isDetailActive) {
                    if let item = selectedGaugingStation {
                        DetailsView(item: item)
                    }
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
                    fetchData()
                }

                .onAppear {
                    if gaugingStationsList.count == 0 {
                        fetchData() // Fetch the data and assign it to the response object
                    } else {
                        print("there is already data in it")
                    }
                }
//                        .overlay(
//                    Text("aaaaaaaaaaaaaa").background(Color.white), alignment: .bottom)
//            .edgesIgnoringSafeArea(Edge.Set(.bottom))
            }
            
            .searchable(text: $searchText)
            .navigationTitle("Gauging Stations")
            
        }
    }

    private func fetchData() {
        Task {
            do {
                print("refreshing data")

                let gaugingStations: [GaugingStationModel] = try await supabase.database
                    .from("gauging_stations_v")
                    .select() // keep it empty for all, else specify returned data
                    .execute()
                    .value

                self.gaugingStationsList = GaugingStationListModel(data: gaugingStations)

            } catch {
                // Handle any errors that occurred during data retrieval
                print("Data Fetch Error: \(error)")
            }
        }
    }
}

struct GaugingStationView_Previews: PreviewProvider {
    static var previews: some View {
        GaugingStationView()
    }
}
