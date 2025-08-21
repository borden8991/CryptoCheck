//
//  CalculatorViewModel.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 21.08.2025.
//

import Foundation

final class CalculatorViewModel {
    
    // MARK: - Properties
    
    private(set) var coins: [CoinModel] = [] {
        didSet { onCoinsUpdated?() }
    }
    
    var inputAmount: Double = 1 {
        didSet { onCoinsUpdated?() }
    }
    
    // MARK: - Callbacks
    
    var onCoinsUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Methods
    
    func fetchCoins() {
        NetworkService.shared.fetchMarketCoins { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coins):
                    self?.coins = coins
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    func numberOfCoins() -> Int {
        coins.count
    }
    
    func coinDisplayText(at index: Int) -> String {
        let coin = coins[index]
        let calculatedValue = inputAmount / coin.currentPrice
        return "\(coin.symbol.uppercased())   \(String(format: "%.6f", calculatedValue))"
    }
}
