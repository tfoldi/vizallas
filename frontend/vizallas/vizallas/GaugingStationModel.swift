//
//  Models.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 18..
//

import Foundation

struct GaugingStationModel: Encodable, Decodable, Identifiable {
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
    subscript(position: Array<GaugingStationModel>.Index) -> GaugingStationModel {
        return gaugingStationData[position]
    }

    public subscript(_: Range<Index>) -> SubSequence { fatalError() }

    var endIndex: Array<GaugingStationModel>.Index {
        gaugingStationData.endIndex
    }

    private var gaugingStationData: [GaugingStationModel] = []

    typealias Element = GaugingStationModel

    typealias Index = Array<GaugingStationModel>.Index

    typealias SubSequence = Array<GaugingStationModel>.SubSequence

    typealias Indices = Array<GaugingStationModel>.Indices

    var startIndex: Array<GaugingStationModel>.Index {
        gaugingStationData.startIndex
    }

    var sections: [String: [GaugingStationModel]]

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
}
