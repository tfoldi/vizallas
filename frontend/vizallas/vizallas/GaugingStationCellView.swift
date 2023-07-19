//
//  GaugingStationCellView.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 19..
//

import SwiftUI


struct GaugingStationCellView: View {
    
    let item: HourlyDataModel
    
    var body: some View {
        return HStack {
            
            VStack(alignment: .leading) {
                Text(item.gaugingStation)
                    .font(.custom("Arial",size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color.primary)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                Text(item.waterflow)
                    .font(.custom("Arial",size: 18))
                    .foregroundColor(Color.secondary)
            }
            Spacer()
            VStack {
                Text(formattedWaterLevel(waterLevel:item.waterLevel))
                    .foregroundColor(Color.primary)
                    .font(.custom("Arial",size: 20))
                Button(formattedWaterLevel(waterLevel: item.diffLastWeekAvgWaterLevel)) {
                    
                }
                .frame(width: 75)
                .padding(5)
                .background(backgroundColorForDiff(value: item.diffLastWeekAvgWaterLevel))
                .foregroundColor(Color.white)
                .cornerRadius(6)
            }
        }
    }
    
    func backgroundColorForDiff(value: Float?) -> Color {
        if let value = value {
            if value.rounded() >= 0 {
                return .green
            } else {
                return .red
            }
        } else {
            return .gray
        }
    }
}
