//
//  CoinDetailCoordinator.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 02.09.2025.
//

import UIKit

final class CoinDetailCoordinator: BaseCoordinator {
    
    private let coin: CoinModel
    
    init(navigationController: UINavigationController, coin: CoinModel) {
        self.coin = coin
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = CoinDetailViewController(coin: coin)
        navigationController.pushViewController(vc, animated: true)
    }
}

