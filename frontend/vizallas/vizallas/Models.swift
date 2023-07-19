//
//  Models.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 18..
//

import Foundation


struct HourlyDataModel: Encodable, Decodable, Identifiable {
    let id: String
    let gaugingStation: String
    let waterflow: String
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case gaugingStation = "gauging_station"
        case waterflow
    }
}

struct HourlyDataListModel: RandomAccessCollection {
    subscript(position: Array<HourlyDataModel>.Index) -> HourlyDataModel {
        get {
            return hourlyData[position]
        }
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence { fatalError() }

    
    var endIndex: Array<HourlyDataModel>.Index {
        hourlyData.endIndex
    }
    

    private var hourlyData: [HourlyDataModel] = []
    
    typealias Element = HourlyDataModel
    
    typealias Index = Array<HourlyDataModel>.Index
    
    typealias SubSequence = Array<HourlyDataModel>.SubSequence
    
    typealias Indices = Array<HourlyDataModel>.Indices
    
    
    var startIndex: Array<HourlyDataModel>.Index {
        hourlyData.startIndex
    }
    

    var sections: [String: [HourlyDataModel]]
    
    init(data: [HourlyDataModel]) {
        hourlyData = data
        sections = Dictionary(grouping: data, by: { $0.waterflow })
    }
    
    var sectionTitles: [String] {
        return sections.keys.sorted()
    }
    
    func items(for section: String) -> [HourlyDataModel] {
        let response = sections[section] ?? []
        let sortedResponse = response.sorted { $0.gaugingStation.localizedCaseInsensitiveCompare($1.gaugingStation) == .orderedAscending }
        
        return sortedResponse
    }
}
