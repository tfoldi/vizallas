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
    @State var selectedHourlyData: HourlyModel?
    @State private var selectedTimeFrame = TimeFrameModel.month
    private let timeFrames = TimeFrameModel.allCases
    @EnvironmentObject private var favorites: GaugingStationFavoritesModel

    init(item: GaugingStationModel) {
        self.item = item
        print("Details: Loading data for \(item.id)")
        _detailsModel = StateObject(wrappedValue: DetailsModel(gaugingStationId: item.id))
    }

    var body: some View {
        VStack(alignment: .leading) {
            if detailsModel.hourlyData.count == 0 {
                ProgressView("Loading details").frame(height: 300)
                    .background(.background)
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.waterflow)
                            .font(.title2)
                            .foregroundColor(.secondary)
                        //                        .padding(.leading, 15)
                        Text(item.measurementDate.formatted())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        //
                    }
                    Spacer()
                    Button {
                        favorites.toggle(item.id)
                    } label: {
                        Label("", systemImage: favorites.contains(item.id) ? "star.fill" : "star")
                    }
                }.padding(.leading, 15)

                VStack {
                    if let data = selectedHourlyData {
                        HStack(alignment: .top) {
                            Text(data.measureDate.formatted())
                                .font(.system(size: 21))
                            Spacer()
                            Text(data.formattedWaterLevel)
                                .bold()
                                .font(.system(size: 21))
                        }
                    } else {
                        Picker("Time frame", selection: $selectedTimeFrame) {
                            ForEach(timeFrames) { timeframe in
                                Text(timeframe.rawValue).tag(timeframe)
                            }
                        }.pickerStyle(.segmented)
                    }
                    Chart {
                        //                RuleMark(y: .value("Limit", 50))
                        ForEach(detailsModel.hourlyData, id: \.self) { item in
                            if selectedTimeFrame.date < item.measureDate {
                                if let waterLevel = item.waterLevel {
                                    PointMark(
                                        x: .value("Index", item.measureDate),
                                        y: .value("Value", waterLevel)
                                    )
                                }
                            }
                        }

                        // highlight
                        if let item = selectedHourlyData, let waterLevel = item.waterLevel {
                            PointMark(
                                x: .value("Index", item.measureDate),
                                y: .value("Value", waterLevel)
                            )
                            .foregroundStyle(Color.orange.gradient)
                            .annotation(
                                position: annotationPosition(measureDate: item.measureDate, waterLevel: waterLevel),
                                spacing: 10
                            ) {
                                DetailsAnnotationView(detail: item, waterLevel: waterLevel)
                                    .opacity(0.97)
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
                                            let selectedIndex = detailsModel.closestMeasureToDate(to: index)
                                            selectedHourlyData = detailsModel.hourlyData.first(where: { $0.measureDate == selectedIndex })
                                        }
                                        .onEnded { _ in
                                            selectedHourlyData = nil
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
                            Text("Date").bold()
                            Spacer()
                            Text(item.measurementDate.formatted())
                        }
                        HStack {
                            Text("Water level").bold()
                            Spacer()
                            if let waterLevel = item.waterLevel {
                                Text("\(Int(waterLevel)) cm")
                            } else {
                                Text("No data")
                            }
                        }
                    }
                }
            }
        }
        .background(Color(uiColor: UIColor.systemGroupedBackground))

        .navigationTitle(item.gaugingStation)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.gaugingStation)
                    .font(.title)
                    .bold()
            }
        }

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

    func annotationPosition(measureDate: Date, waterLevel: Float) -> AnnotationPosition {
        if let p25 = detailsModel.calculatePercentile(25),
           let p75 = detailsModel.calculatePercentile(75)
        {
            print("wl=\(waterLevel) p25=\(p25) p75=\(p75) ")

            let position: AnnotationPosition

            if measureDate < selectedTimeFrame.halfTime && waterLevel >= p75 {
                position = .bottomTrailing
            } else if measureDate >= selectedTimeFrame.halfTime && waterLevel >= p75 {
                position = .bottomLeading
            } else if measureDate >= selectedTimeFrame.halfTime && waterLevel > p25 && waterLevel < p75 {
                position = .leading

            } else if measureDate < selectedTimeFrame.halfTime && waterLevel > p25 && waterLevel < p75 {
                position = .trailing
            } else if measureDate < selectedTimeFrame.halfTime && waterLevel <= p25 {
                position = .topTrailing
            } else if measureDate >= selectedTimeFrame.halfTime && waterLevel <= p25 {
                position = .topLeading
            } else {
                position = .leading
            }

            return position

        } else {
            print("not matched in annotationPosition")
            return .leading
        }
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(item: GaugingStationModel(id: "Göd-Duna", gaugingStation: "Göd", waterflow: "Duna", waterLevel: Optional(100), diffLastWeekAvgWaterLevel: Optional(10), measurementDate: Date()))
            .environmentObject(GaugingStationFavoritesModel())
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
        .background(.background)
        .opacity(1)
    }
}
