//
//  Utils.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 18..
//

import Foundation
import SwiftUI

func compareDiacriticInsensitive(base: String, searchText: String) -> Bool {
    return base.range(of: searchText, options: [NSString.CompareOptions.caseInsensitive, .diacriticInsensitive]) != nil
}

func formattedWaterLevel(waterLevel: Float?) -> String {
    if let value = waterLevel {
        return String(format: "%d cm", Int(value.rounded()))
    } else {
        return "No data"
    }
}

extension Binding where Value == String? {
    var isNotNil: Binding<Bool> {
        Binding<Bool>(
            get: { self.wrappedValue != nil },
            set: { if !$0 { self.wrappedValue = nil } }
        )
    }
}
