//
//  ContentView.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 18..
//

import SwiftUI

struct ContentView: View {
    @State private var response: [GaugingStationModel] = []
    @State private var searchText: String = ""
    @State private var isHomeActive = false

    
    var filteredResponse: GaugingStationListModel {
        
        if searchText.isEmpty {
            return GaugingStationListModel(data: response)
        } else {
            return GaugingStationListModel(data:  response.filter {
                compareDiacriticInsensitive(base: $0.gaugingStation, searchText: searchText) ||
                compareDiacriticInsensitive(base: $0.waterflow, searchText: searchText)
            })
            
        }
        
    }
    
    
    var body: some View {
        NavigationStack {
            
            
            VStack {
                TextField("Search", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                List {
                    ForEach(filteredResponse.sectionTitles, id: \.self) { section in
                        Section(header: Text(section)) {
                            ForEach(filteredResponse.items(for: section)) { item in
                                GaugingStationCellView(item: item)
//                                HStack {
//                                    Text(item.gaugingStation)
//                                    Spacer()
//                                    FavoriteButton(isFavorite: false) {
//                                        toggleFavorite(for: item)
//                                    }
//                                }
                                
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Gauging Stations")
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

                .onAppear {
                    fetchData() // Fetch the data and assign it to the response object
                }

            }
//            .padding()
            .edgesIgnoringSafeArea(Edge.Set(.bottom))
        }
    }
    
    private func toggleFavorite(for item: GaugingStationModel) {
        // Toggle the favorite state for the item
        //item.isFavorite.toggle()
    }
    
    private func fetchData() {
        Task {
            do {
                self.response = try await supabase.database
                    .from("gauging_stations_v")
                    .select() // keep it empty for all, else specify returned data
                    .execute()
                    .value
                
            } catch {
                // Handle any errors that occurred during data retrieval
                print("Data Fetch Error: \(error)")
            }
        }
    }
}



struct FavoriteButton: View {
    @State private var isFavorite: Bool
    private let action: () -> Void
    
    init(isFavorite: Bool, action: @escaping () -> Void) {
        self._isFavorite = State(initialValue: isFavorite)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct HomeView: View {
    var body: some View {
        Text("Home View")
            .navigationTitle("Home")
    }
}
