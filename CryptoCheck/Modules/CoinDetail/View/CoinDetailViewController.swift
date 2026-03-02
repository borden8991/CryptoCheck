//
//  CoinDetailViewController.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 19.08.2025.
//

import UIKit
import SwiftUI
import SnapKit

final class CoinDetailViewController: UIViewController {
    
    // MARK: - Properties
    
    private let coin: CoinModel
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()
    private let marketCapLabel = UILabel()
    private let supplyLabel = UILabel()
    private let intervals = ChartInterval.allCases
    private lazy var periodSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: intervals.map(\.title))
        return control
    }()
    private var currentInterval: String = "1"
    private var chartPrices: [(Double, Double)] = [] {
        didSet { updateChart() }
    }
    
    private lazy var chartHostingController = UIHostingController(rootView: CoinChartView(prices: [], interval: ChartInterval.day))

    // MARK: Init
    
    init(coin: CoinModel) {
        self.coin = coin
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = coin.name
        
        setupPriceSection()
        setupChartAndSegmentedControl()
        setupInfoLabels()
        fetchChartData(days: "1")
    }
    
    // MARK: Setup
    
    private func setupPriceSection() {
        priceLabel.font = .boldSystemFont(ofSize: 28)
        priceLabel.text = "\(coin.currentPrice) $"
        view.addSubview(priceLabel)
        
        changeLabel.font = .systemFont(ofSize: 16)
        changeLabel.textColor = (coin.priceChangePercentage24H ?? 0) >= 0 ? .systemGreen : .systemRed
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
    
    private func setupChartAndSegmentedControl() {
        
        let chartContainer = UIView()
        chartContainer.clipsToBounds = true
        chartContainer.layer.masksToBounds = true
        view.addSubview(chartContainer)
        chartContainer.snp.makeConstraints { make in
            make.top.equalTo(changeLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(300)
        }
        
        addChild(chartHostingController)
        chartContainer.addSubview(chartHostingController.view)
        chartHostingController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        chartHostingController.didMove(toParent: self)
        
        periodSegmentedControl.selectedSegmentIndex = intervals.firstIndex(of: .day) ?? 0
        periodSegmentedControl.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        view.addSubview(periodSegmentedControl)
        
        periodSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(chartContainer.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
    }
    
    private func setupInfoLabels() {
        marketCapLabel.text = "Рыночная капитализация: \(coin.marketCap)"
        supplyLabel.text = "В обращении: \(coin.circulatingSupply)"
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
    
    // MARK: Actions
    
    @objc private func periodChanged() {
        let selected = intervals[periodSegmentedControl.selectedSegmentIndex]
        fetchChartData(days: selected.apiDays)
    }
    
    // MARK: Networking
    
    private func fetchChartData(days: String) {
        NetworkService.shared.fetchCoinMarketChart(coinID: coin.id, days: days) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let prices):
                    self?.chartPrices = prices
                case .failure(let error):
                    print("Ошибка графика: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: Update SwiftUI Chart
    
    private func updateChart() {
        chartHostingController.rootView = CoinChartView(prices: chartPrices,
                                                        interval: intervals[periodSegmentedControl.selectedSegmentIndex])
        updateRangeLabel()
    }
    
    private func updateRangeLabel() {
        //TODO: - Доработать расчет процентов
        guard let first = chartPrices.first?.1,
              let last = chartPrices.last?.1 else {
            changeLabel.text = "Нет данных"
            return
        }
        
        let change = last - first
        let percentChange = (change / first) * 100
        
        let sign = change >= 0 ? "+" : ""
        changeLabel.textColor = change >= 0 ? .systemGreen : .systemRed
        changeLabel.text = String(
            format: "%@%.2f (%.2f%%)",
            sign, change, percentChange
        )
    }
}
