//
//  CoinChartView.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 06.09.2025.
//

import Foundation
import SwiftUI
import Charts

enum ChartInterval: CaseIterable {
    case hour, day, week, month, year
    
    var title: String {
        switch self {
        case .hour: return "1H"
        case .day: return "24H"
        case .week: return "7D"
        case .month: return "1M"
        case .year: return "1Y"
        }
    }
    
    var apiDays: String {
        switch self {
        case .hour: return "0.04"
        case .day: return "1"
        case .week: return "7"
        case .month: return "30"
        case .year: return "365"
        }
    }
    
    var desiredTickCount: Int {
        switch self {
        case .hour, .day: return 6
        case .week: return 6
        case .month: return 6
        case .year: return 6
        }
    }
    
    var axisFormat: Date.FormatStyle {
        switch self {
        case .hour, .day:
            return .dateTime.hour().minute()
        case .week, .month:
            return .dateTime.day().month(.abbreviated)
        case .year:
            return .dateTime.month(.abbreviated)
        }
    }
}

struct CoinChartView: View {
    let prices: [(Double, Double)]
    let interval: ChartInterval
    
    @State private var selectedPrice: (Date, Double)? = nil
    
    private var yDomain: ClosedRange<Double> {
        guard let minPrice = prices.map({ $0.1 }).min(),
              let maxPrice = prices.map({ $0.1 }).max()
        else { return 0...1 }
        let range = maxPrice - minPrice
        let topPadding = range * 0.1        // 10% сверху
        let bottomPadding = range * 0.05    // 5% снизу
        let lowerBound = max(minPrice - bottomPadding, minPrice * 0.98)
        let upperBound = maxPrice + topPadding
        
        return lowerBound...upperBound
    }
    
    private var xDomain: ClosedRange<Date> {
        guard let first = prices.first?.0,
              let last = prices.last?.0 else {
            return Date()...Date()
        }
        return Date(timeIntervalSince1970: first / 1000)...Date(timeIntervalSince1970: last / 1000)
    }
    
    var body: some View {
        Chart {
            ForEach(prices, id: \.0) { point in
                let date = Date(timeIntervalSince1970: point.0 / 1000)
                
                LineMark(
                    x: .value("Дата", date),
                    y: .value("Цена", point.1)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                AreaMark(
                    x: .value("Дата", date),
                    yStart: .value("Цена", yDomain.lowerBound),
                    yEnd: .value("Цена", point.1)
                )
                .foregroundStyle(
                    .linearGradient(
                        Gradient(colors: [.blue.opacity(0.3), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            if let selected = selectedPrice {
                RuleMark(x: .value("Выбор", selected.0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(.gray)
                
                PointMark(
                    x: .value("Дата", selected.0),
                    y: .value("Цена", selected.1)
                )
                .foregroundStyle(.red)
                .symbolSize(100)
                .annotation(position: .topLeading) {
                    Text("\(selected.1, format: .number.precision(.fractionLength(2))) $")
                        .font(.caption)
                        .padding(6)
                        .background(Color.black.opacity(0.8), in: RoundedRectangle(cornerRadius: 6))
                        .foregroundColor(.white)
                }
            }
        }
        .chartYScale(domain: yDomain)
        .chartYAxis { AxisMarks(position: .leading) }
        .chartXScale(domain: xDomain)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: interval.desiredTickCount)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date, format: interval.axisFormat)
                    }
                }
            }
        }
        .frame(height: 300)
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                if let date: Date = proxy.value(atX: x) {
                                    if let nearest = nearestPrice(to: date) {
                                        selectedPrice = nearest
                                    }
                                }
                            }
                            .onEnded { _ in
                                selectedPrice = nil
                            }
                    )
            }
        }
        .transaction { $0.animation = nil }
        
    }
    
    private func nearestPrice(to date: Date) -> (Date, Double)? {
        guard !prices.isEmpty else { return nil }
        let target = date.timeIntervalSince1970
        let mapped = prices.map { (Date(timeIntervalSince1970: $0.0 / 1000), $0.1) }
        return mapped.min(by: { abs($0.0.timeIntervalSince1970 - target) < abs($1.0.timeIntervalSince1970 - target) })
    }
}

#Preview {
    CoinChartView(
        prices: [
            (0, 65000),
            (1, 66000),
            (2, 67000),
            (3, 66500),
            (4, 67500)
        ],
        interval: ChartInterval.week
    )
    .frame(height: 300)
    .padding()
}
