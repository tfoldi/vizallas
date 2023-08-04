//
//  Models.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 18..
//

import Foundation

struct GaugingStationModel: Encodable, Decodable, Identifiable, Hashable {
    let id: String
    let gaugingStation: String
    let waterflow: String
    let waterLevel: Float?
    let diffLastWeekAvgWaterLevel: Float?
    let measurementDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case gaugingStation = "gauging_station"
        case waterflow
        case waterLevel = "water_level"
        case diffLastWeekAvgWaterLevel = "diff_last_week_avg_water_level"
        case measurementDate = "measure_date"
    }
}

class GaugingStationListModel: RandomAccessCollection, ObservableObject {
    @Published private var gaugingStationData: [GaugingStationModel] = []

    @Published var sections: [String: [GaugingStationModel]]

    subscript(position: Array<GaugingStationModel>.Index) -> GaugingStationModel {
        return gaugingStationData[position]
    }

    public subscript(_: Range<Index>) -> SubSequence { fatalError() }

    var endIndex: Array<GaugingStationModel>.Index {
        gaugingStationData.endIndex
    }

    typealias Element = GaugingStationModel

    typealias Index = Array<GaugingStationModel>.Index

    typealias SubSequence = Array<GaugingStationModel>.SubSequence

    typealias Indices = Array<GaugingStationModel>.Indices

    var startIndex: Array<GaugingStationModel>.Index {
        gaugingStationData.startIndex
    }

    init(data: [GaugingStationModel]) {
        gaugingStationData = data
        sections = Dictionary(grouping: data, by: { $0.waterflow })
    }

    var sectionTitles: [String] {
        return sections.keys.sorted()
    }

    func items(for section: String) -> [GaugingStationModel] {
        let response = sections[section] ?? []
        let sortedResponse = response.sorted { $0.gaugingStation.localizedCaseInsensitiveCompare($1.gaugingStation) == .orderedAscending }

        return sortedResponse
    }

    func gaugingStations() -> [GaugingStationModel] {
        return gaugingStationData
    }

    func fetchData() async throws {
        print("refreshing data")

        let gaugingStationData: [GaugingStationModel] = try await supabase.database
            .from("gauging_stations_v")
            .select() // keep it empty for all, else specify returned data
            .execute()
            .value

        print("Gaug count \(gaugingStationData.count)")

        DispatchQueue.main.async {
            self.gaugingStationData = gaugingStationData
            self.sections = Dictionary(grouping: gaugingStationData, by: { $0.waterflow })
        }
        print("Gaug2 count \(self.gaugingStationData.count)")
    }
}

class GaugingStationFavoritesModel: ObservableObject {
    @Published private var _favorites: [String]
    private let userDefaultKey = "FavoriteGaugingStations"

    init() {
        _favorites = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] ?? [String]()
    }

    var favorites: [String] {
        return _favorites
    }

    var count: Int {
        _favorites.count
    }

    func remove(favorite: String) {
        DispatchQueue.main.async {
            self._favorites.removeAll(where: { $0 == favorite })
            UserDefaults.standard.set(self._favorites, forKey: self.userDefaultKey)
        }
    }

    func contains(_ favorite: String) -> Bool {
        print("contains: \(favorite) in \(_favorites)")
        return _favorites.contains(where: { $0 == favorite })
    }

    func toggle(_ favorite: String) {
        if contains(favorite) {
            remove(favorite: favorite)
        } else {
            add(favorite: favorite)
        }
    }

    func add(favorite: String) {
        if !contains(favorite) {
            DispatchQueue.main.async {
                self._favorites.append(favorite)
                UserDefaults.standard.set(self._favorites, forKey: self.userDefaultKey)
            }
        }
    }
}
