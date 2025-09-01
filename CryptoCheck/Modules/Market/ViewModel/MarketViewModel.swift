//
//  CryptoListViewModel.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 31.07.2025.
//

import Foundation

enum CurrencyMode {
    case usd
    case btc
}

final class MarketViewModel {
    
    // MARK: - Properties
    
    private(set) var coins: [CoinModel] = []
    private(set) var filteredCoins: [CoinModel] = []
    private(set) var btcPrice: Double = 1.0
    private(set) var isLoading: Bool = false
    
    private var isMarketCapSortedDescending = false
    
    var currencyMode: CurrencyMode = .usd
    
    // MARK: - Callbacks
    
    var onLoadingStatusChanged: ((Bool) -> Void)?
    var onUpdate: (() -> Void)?
    
    // MARK: - Public API
    
    func fetchCoins(search: String = "", completion: (() -> Void)? = nil) {
        isLoading = true
        onLoadingStatusChanged?(true)
        
        if search.isEmpty {
            NetworkService.shared.fetchMarketCoins { [weak self] result in
                DispatchQueue.main.async {
                    self?.handleFetchResult(result)
                    self?.isLoading = false
                    self?.onLoadingStatusChanged?(false)
                    completion?()
                }
            }
        } else {
            fetchCoinsByIDs(ids: search, completion: completion)
        }
    }
    
    func toggleSortByMarketCap() {
        isMarketCapSortedDescending.toggle()
        filteredCoins.sort { lhs, rhs in
            isMarketCapSortedDescending
                ? lhs.marketCap < rhs.marketCap
                : lhs.marketCap > rhs.marketCap
        }
        onUpdate?()
    }
    
    func filterCoins(searchText: String) {
        filteredCoins = searchText.isEmpty
        ? coins
        : coins.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.symbol.lowercased().contains(searchText.lowercased())
        }
        onUpdate?()
    }
    
    func setCurrencyMode(_ mode: CurrencyMode) {
        currencyMode = mode
        onUpdate?()
    }
    
    func price(for coin: CoinModel) -> Double {
        switch currencyMode {
        case .usd:
            return coin.currentPrice
        case .btc:
            guard btcPrice > 0 else { return 0 }
            return coin.currentPrice / btcPrice
        }
    }
    
    func numberOfItems() -> Int {
        filteredCoins.count
    }
    
    func coin(at index: Int) -> CoinModel {
        filteredCoins[index]
    }
    
    // MARK: - Private Helpers
    
    private func handleFetchResult(_ result: Result<[CoinModel], Error>) {
        switch result {
        case .success(let coins):
            self.coins = coins
            self.filteredCoins = coins
            
            if let btc = coins.first(where: { $0.symbol.lowercased() == "btc" }) {
                self.btcPrice = btc.currentPrice
            }
            onUpdate?()
        case .failure(let error):
            print("Error fetching market coins: \(error.localizedDescription)")
        }
    }
    
    private func fetchCoinsByIDs(ids: String, completion: (() -> Void)? = nil) {
        NetworkService.shared.fetchMarketCoinsByIDs(ids: ids) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let coins):
                    self.filteredCoins = coins
                    if let btc = coins.first(where: { $0.symbol.lowercased() == "btc" }) {
                        self.btcPrice = btc.currentPrice
                    }
                    self.onUpdate?()
                case .failure(let error):
                    print("Error fetching coins by IDs: \(error.localizedDescription)")
                }
                
                self.isLoading = false
                self.onLoadingStatusChanged?(false)
                completion?()
            }
        }
    }
}
