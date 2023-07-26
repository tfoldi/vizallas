//
//  DetailsView.swift
//  vizallas
//
//  Created by Tamas Foldi on 2023. 07. 22..
//

import Charts
import SwiftUI

struct DetailsView: View {
    let item: GaugingStationModel
    @StateObject var detailsModel: DetailsModel
    @State private var selectedTimeFrame = TimeFrameModel.month
    let timeFrames = TimeFrameModel.allCases
    @State private var selectedIndex: Date? = nil

    init(item: GaugingStationModel) {
        self.item = item
        print("Details: Loading data for \(item.id)")
        _detailsModel = StateObject(wrappedValue: DetailsModel(gaugingStationId: item.id))
    }

    var body: some View {
        //        NavigationStack {
        VStack {
            //            TabView {
            //                Text("Details View for \(item.gaugingStation)")
            if detailsModel.hourlyData.count == 0 {
                ProgressView("Loading details").frame(height: 300)
                    .background(.background)
            } else {
                VStack {
                    Picker("Time frame", selection: $selectedTimeFrame) {
                        ForEach(timeFrames) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }.pickerStyle(.segmented)
                    Chart {
                        //                RuleMark(y: .value("Limit", 50))
                        ForEach(detailsModel.hourlyData, id: \.self) { item in
                            if selectedTimeFrame.date < item.measureDate {
                                if let waterLevel = item.waterLevel {
                                    PointMark(
                                        x: .value("Index", item.measureDate),
                                        y: .value("Value", waterLevel)
                                    )

                                    if let selectedIndex, selectedIndex == item.measureDate {
                                        RectangleMark(
                                            x: .value("Index", selectedIndex),
                                            //                                                y: .value("Value", waterLevel)
                                            yStart: .value("Value", 0),
                                            yEnd: .value("Value", waterLevel),
                                            width: 2
                                        )
                                        .foregroundStyle(Color.orange.gradient)
                                        //                                            .opacity(0.4)
                                        .annotation(
                                            position: item.measureDate < selectedTimeFrame.halfTime ? .trailing : .leading,
                                            alignment: .trailing, spacing: 10
                                        ) {
                                            DetailsAnnotationView(detail: item, waterLevel: waterLevel)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .chartOverlay { chart in
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let currentX = value.location.x - geometry[chart.plotAreaFrame].origin.x
                                            guard currentX >= 0, currentX < chart.plotAreaSize.width else {
                                                return
                                            }

                                            guard let index = chart.value(atX: currentX, as: Date.self) else {
                                                return
                                            }
                                            selectedIndex = detailsModel.closestMeasureToDate(to: index)
                                        }
                                        .onEnded { _ in
                                            selectedIndex = nil
                                        }
                                )
                        }
                    }

                    .background(.background)
                    .cornerRadius(8)
                    .frame(height: 300)
                    //            }
                }
                .padding()
                List {
                    Section(header: Text("Station info")) {
                        HStack {
                            Text("Water level").bold()
                            Spacer()
                            if let waterLevel = item.waterLevel {
                                Text("\(Int(waterLevel)) cm")
                            } else {
                                Text("No data")
                            }
                        }
                        HStack {
                            Text("Barfoo").bold()
                            Spacer()
                            Text("10 cm")
                        }
                    }
                }
            }
        }
        .background(Color(uiColor: UIColor.systemGroupedBackground))

        .navigationTitle(item.gaugingStation)
        .refreshable {
            do {
                try await detailsModel.fetchData()
            } catch {
                print("fetch failed: \(error)")
            }
        }

        .task {
            print("getting id \(item.id) and \(detailsModel.gaugingStationId)")
            do {
                try await detailsModel.fetchData()
            } catch {
                print("fetch failed: \(error)")
            }
        }
        //    }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(item: GaugingStationModel(id: "Budapest-Duna", gaugingStation: "Budapest", waterflow: "Duna", waterLevel: Optional(100), diffLastWeekAvgWaterLevel: Optional(10)))
    }
}

struct DetailsAnnotationView: View {
    let detail: HourlyModel
    let waterLevel: Float

    var body: some View {
        VStack(alignment: .leading) {
            Text(detail.measureDate.formatted())
                .font(.caption)
//            Text("YEE")
//                .font(.headline)
//            Divider()
            Text("\(Int(waterLevel)) cm")
                .bold()
        }
        .padding()
//        .background(.background)
//        .opacity(1)
    }
}
