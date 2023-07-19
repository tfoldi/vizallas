//
//  Utils.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 18..
//

import Foundation


func compareDiacriticInsensitive(base:String, searchText: String) -> Bool {
    return base.range(of: searchText, options: [NSString.CompareOptions .caseInsensitive, .diacriticInsensitive]) != nil
}

