//
//  CoinDetailViewController.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 19.08.2025.
//

import UIKit
import SnapKit
import DGCharts

final class CoinDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let coin: CoinModel
    private let chartView = LineChartView()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()
    private let periodSegmentedControl = UISegmentedControl(items: ["1H", "24H", "7D", "30D", "1Y"])
    private let marketCapLabel = UILabel()
    private let supplyLabel = UILabel()
    
    private var currentInterval: String = "1"
    
    // MARK: - Init
    
    init(coin: CoinModel) {
        self.coin = coin
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchChartData(days: "1")
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = coin.name
        
        setupPriceSection()
        setupChart()
        setupSegmentedControl()
        setupInfoLabels()
    }
    
    func setupPriceSection() {
        priceLabel.font = .boldSystemFont(ofSize: 28)
        priceLabel.textColor = .label
        priceLabel.text = "\(coin.currentPrice) $"
        
        changeLabel.font = .systemFont(ofSize: 16)
        changeLabel.textColor = (coin.priceChangePercentage24H ?? 0) >= 0 ? .systemGreen : .systemRed
        changeLabel.text = "\(coin.priceChangePercentage24H ?? 0)% (24H)"
        
        view.addSubview(priceLabel)
        view.addSubview(changeLabel)
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.leading.equalTo(priceLabel)
        }
    }
    
    func setupChart() {
        view.addSubview(chartView)
        
        chartView.snp.makeConstraints { make in
            make.top.equalTo(changeLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(300)
        }
        
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.legend.enabled = false
    }
    
    func setupSegmentedControl() {
        periodSegmentedControl.selectedSegmentIndex = 1
        periodSegmentedControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        
        view.addSubview(periodSegmentedControl)
        periodSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(chartView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
    }
    
    func setupInfoLabels() {
        marketCapLabel.text = "Рыночная капитализация: \(coin.marketCap)"
        marketCapLabel.font = .systemFont(ofSize: 16)
        
        supplyLabel.text = "В обращении: \(coin.circulatingSupply)"
        supplyLabel.font = .systemFont(ofSize: 16)
        
        view.addSubview(marketCapLabel)
        view.addSubview(supplyLabel)
        
        marketCapLabel.snp.makeConstraints { make in
            make.top.equalTo(periodSegmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        supplyLabel.snp.makeConstraints { make in
            make.top.equalTo(marketCapLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Actions
    
    @objc func periodChanged() {
        let selected = periodSegmentedControl.selectedSegmentIndex
        let days = ["0.04", "1", "7", "30", "365"][selected]
        currentInterval = days
        fetchChartData(days: days)
    }
    
    // MARK: - Networking
    
    func fetchChartData(days: String) {
        NetworkService.shared.fetchCoinMarketChart(coinID: coin.id, days: days) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let prices):
                    self?.setChartData(prices: prices)
                case .failure(let error):
                    print("Ошибка графика: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Chart Configuration
    
    func setChartData(prices: [(Double, Double)]) {
        let entries = prices.map { ChartDataEntry(x: $0.0, y: $0.1) }
        let dataSet = LineChartDataSet(entries: entries, label: "")
        
        dataSet.colors = [.systemBlue]
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 2
        dataSet.mode = .cubicBezier
        dataSet.drawValuesEnabled = false
        dataSet.fillColor = .systemBlue
        dataSet.fillAlpha = 0.3
        dataSet.drawFilledEnabled = true
        
        chartView.data = LineChartData(dataSet: dataSet)
        chartView.xAxis.valueFormatter = DateValueFormatter(interval: currentInterval)
    }
}

// MARK: - DateValueFormatter

final class DateValueFormatter: AxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    init(interval: String) {
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        switch interval {
        case "0.04", "1":
            dateFormatter.dateFormat = "HH:mm"
        case "7", "30":
            dateFormatter.dateFormat = "dd MMM"
        case "365", "max":
            dateFormatter.dateFormat = "MMM yy"
        default:
            dateFormatter.dateFormat = "dd MMM"
        }
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let date = Date(timeIntervalSince1970: value / 1000.0)
        return dateFormatter.string(from: date)
    }
}
