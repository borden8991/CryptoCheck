//
//  MarketViewController.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 31.07.2025.
//

import UIKit
import SnapKit

final class MarketViewController: UIViewController {
    
    var onCoinSelected: ((CoinModel) -> Void)?
    var onSearchRequested: (() -> Void)?
    
    // MARK: - Properties
    
    private let viewModel = MarketViewModel()
    
    private let refreshControl = UIRefreshControl()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MarketCell.self, forCellReuseIdentifier: MarketCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let marketCapHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Market Cap"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let currencySwitch: UISegmentedControl = {
        let control = UISegmentedControl(items: ["USD", "BTC"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private var timer: Timer?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupNavigationBar()
        setupHeaderTapGesture()
        bindViewModel()
        startAutoRefresh()
        
        viewModel.fetchCoins { [weak self] in
            self?.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadData),
            name: NSNotification.Name("ColorBlindModeChanged"),
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoRefresh()
    }
    
    deinit {
        stopAutoRefresh()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView.tableHeaderView = makeTableHeader()
        
        currencySwitch.addTarget(self, action: #selector(currencyChanged), for: .valueChanged)
        
        view.addSubview(currencySwitch)
        view.addSubview(tableView)
        
        currencySwitch.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(8)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(currencySwitch.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func makeTableHeader() -> UIView {
        let container = UIView()
        
        let numberLabel = makeHeaderLabel(text: "#", alignment: .center)
        let nameLabel = makeHeaderLabel(text: "Coin", alignment: .center)
        let priceLabel = makeHeaderLabel(text: "Price", alignment: .right)
        let changeLabel = makeHeaderLabel(text: "24h %", alignment: .right)
        let marketCapLabel = marketCapHeaderLabel
        
        [numberLabel, nameLabel, priceLabel, changeLabel, marketCapLabel].forEach {
            container.addSubview($0)
        }
        
        numberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(30).priority(.low)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(numberLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(50).priority(.low)
        }
        
        priceLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(80).priority(.low)
        }
        
        changeLabel.snp.makeConstraints {
            $0.leading.equalTo(priceLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60).priority(.low)
        }
        
        marketCapLabel.snp.makeConstraints {
            $0.leading.equalTo(changeLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
        }
        
        container.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 40)
        return container
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupNavigationBar() {
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(didTapSearch)
        )
        navigationItem.rightBarButtonItem = searchButton
    }
    
    private func setupHeaderTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMarketCapHeader))
        marketCapHeaderLabel.addGestureRecognizer(tapGesture)
    }
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func reloadData() {
        tableView.reloadData()
    }
    
    @objc private func refreshData() {
        viewModel.fetchCoins { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc private func didTapSearch() {
        tabBarController?.selectedIndex = 2
    }
    
    @objc private func didTapMarketCapHeader() {
        viewModel.toggleSortByMarketCap()
    }
    
    @objc private func currencyChanged() {
        if currencySwitch.selectedSegmentIndex == 0 {
            viewModel.setCurrencyMode(.usd)
        } else {
            viewModel.setCurrencyMode(.btc)
        }
    }
    
    // MARK: - Auto Refresh
    
    private func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.viewModel.fetchCoins()
        }
    }
    
    private func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Helpers
    
    private func makeHeaderLabel(text: String, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = alignment
        label.numberOfLines = 1
        return label
    }
}

// MARK: - UITableViewDataSource

extension MarketViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MarketCell.identifier, for: indexPath) as? MarketCell else { return UITableViewCell() }
        let coin = viewModel.coin(at: indexPath.row)
        let price = viewModel.price(for: coin)
        cell.configure(with: coin, price: price, index: indexPath.row + 1, currencyMode: viewModel.currencyMode)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = viewModel.coins[indexPath.row]
        let detailVC = CoinDetailViewController(coin: coin)
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension MarketViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}
