//
//  SearchViewController.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 13.08.2025.
//

import UIKit

final class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    private var coins: [CoinModel] = []
    private var timer: Timer?
    
    private let viewModel = MarketViewModel()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(MarketCell.self, forCellReuseIdentifier: MarketCell.identifier)
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Поиск монет"
        sb.searchBarStyle = .minimal
        return sb
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        navigationItem.titleView = searchBar
        
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Networking
    
    private func searchCoins(query: String) {
        guard !query.isEmpty else {
            coins.removeAll()
            tableView.reloadData()
            return
        }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            NetworkService.shared.fetchSearchCoins(query: query) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let searchResponse):
                        let ids = searchResponse.coins.map { $0.id }.joined(separator: ",")
                        guard !ids.isEmpty else {
                            self?.coins.removeAll()
                            self?.tableView.reloadData()
                            return
                        }
                        
                        NetworkService.shared.fetchMarketCoinsByIDs(ids: ids) { marketResult in
                            DispatchQueue.main.async {
                                switch marketResult {
                                case .success(let coins):
                                    self?.coins = coins
                                    self?.tableView.reloadData()
                                case .failure(let error):
                                    print("Ошибка загрузки данных по ID: \(error.localizedDescription)")
                                }
                            }
                        }
                    case .failure(let error):
                        print("Ошибка поиска: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCoins(query: searchText)
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MarketCell.identifier,
            for: indexPath
        ) as? MarketCell else {
            return UITableViewCell()
        }
        
        let coin = coins[indexPath.row]
        let price = viewModel.price(for: coin)
        
        cell.configure(with: coin, price: price, index: indexPath.row + 1, currencyMode: viewModel.currencyMode)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = coins[indexPath.row]
        let detailVC = CoinDetailViewController(coin: coin)
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
