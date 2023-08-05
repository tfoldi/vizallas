//
//  DetailsModel.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 22..
//

import Foundation

struct HourlyModel: Encodable, Decodable, Identifiable, Hashable {
    let id: String
    let gaugingStation: String
    let measureDate: Date
    let waterflow: String
    let waterLevel: Float?
    let waterDischarge: Float?
    let gaugingStationId: String
//    let loadDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case gaugingStation = "gauging_station"
        case measureDate = "measure_date"
        case waterflow
        case waterLevel = "water_level"
        case waterDischarge = "water_discharge"
        case gaugingStationId = "gauging_station_id"
//        case loadDate = "load_dt"
    }

    var formattedWaterLevel: String {
        if let _waterLevel = waterLevel {
            return "\(Int(_waterLevel)) cm"
        } else {
            return "Unknown"
        }
    }
}

class DetailsModel: ObservableObject {
    @Published private var _hourlyData: [HourlyModel] = []

    let gaugingStationId: String

    init(gaugingStationId: String) {
        self.gaugingStationId = gaugingStationId
    }

    var hourlyData: [HourlyModel] {
        return _hourlyData
    }

    func fetchData() async throws {
        print("getting hourly data for \(gaugingStationId)")

        let hourlyData: [HourlyModel] = try await supabase.database
            .from("hourly_data")
            .select() // keep it empty for all, else specify returned data
            .eq(column: "gauging_station_id", value: gaugingStationId)
            .execute()
            .value

        DispatchQueue.main.async {
            self._hourlyData = hourlyData
        }
    }

    func closestMeasureToDate(to date: Date) -> Date? {
        return _hourlyData.min { a, b in
            abs(date.timeIntervalSince(a.measureDate)) < abs(date.timeIntervalSince(b.measureDate))
        }?.measureDate
    }
}

enum TimeFrameModel: String, CaseIterable, Identifiable {
    var id: String { rawValue }

    var firstDate: Date {
        return Calendar.current.date(from: DateComponents(year: 2023, month: 6, day: 25))!
    }

    case week = "Last 7 Days"
    case month = "Last 30 Days"
    case year = "Last 365 Days"

    var date: Date {
        switch self {
        case .week:
            return Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        case .month:
            return Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        case .year:
            return Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        }
    }

    var halfTime: Date {
        switch self {
        case .week:
            return Calendar.current.date(byAdding: .hour, value: -84, to: Date())!
        case .month:
            return Calendar.current.date(byAdding: .day, value: -15, to: Date())!
        case .year:
            return max(Date().addingTimeInterval(Date().timeIntervalSince(firstDate) / 2 * -1), Calendar.current.date(byAdding: .day, value: -183, to: Date())!)
        }
    }
}
