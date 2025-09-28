//
//  MarketCoordinator.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 02.09.2025.
//

import UIKit

final class MarketCoordinator: BaseCoordinator {
    
    override func start() {
        let vc = MarketViewController()
        
        vc.onCoinSelected = { [weak self] coin in
            guard let self else { return }
            let detailCoordinator = CoinDetailCoordinator(navigationController: self.navigationController, coin: coin)
            self.store(detailCoordinator)
            detailCoordinator.start()
        }
        
        vc.onSearchRequested = { [weak self] in
            self?.navigationController.tabBarController?.selectedIndex = 2
        }
        navigationController.setViewControllers([vc], animated: false)
    }
}
