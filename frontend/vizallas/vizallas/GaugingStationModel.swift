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

    enum CodingKeys: String, CodingKey {
        case id
        case gaugingStation = "gauging_station"
        case waterflow
        case waterLevel = "water_level"
        case diffLastWeekAvgWaterLevel = "diff_last_week_avg_water_level"
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
