//
//  GaugingStationDescModel.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 08. 05..
//

import Foundation

struct GaugingStationDescData: Encodable, Decodable, Identifiable, Hashable {
    let id: Int
    let gaugingStation: String
    let waterflow: String
    let name: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case id
        case gaugingStation = "gauging_station"
        case waterflow
        case name
        case value
    }
}

class GaugingStationDescModel: ObservableObject {
    @Published private var _descData: [GaugingStationDescData] = []

    let gaugingStation: String
    let waterflow: String

    init(gaugingStation: String, waterflow: String) {
        self.gaugingStation = gaugingStation
        self.waterflow = waterflow
    }

    var descData: [GaugingStationDescData] {
        return _descData
    }

    func fetchData() async throws {
        print("GaugingStationDescModel for \(gaugingStation)")

        let _descData: [GaugingStationDescData] = try await supabase.database
            .from("gauging_station_desc")
            .select() // keep it empty for all, else specify returned data
            .eq(column: "gauging_station", value: gaugingStation)
            .eq(column: "waterflow", value: waterflow)
            .order(column: "id")
            .execute()
            .value

        DispatchQueue.main.async {
            self._descData = _descData
        }
    }
}
