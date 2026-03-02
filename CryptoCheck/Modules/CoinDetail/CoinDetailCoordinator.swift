//
//  CoinDetailCoordinator.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 02.09.2025.
//

import UIKit

final class CoinDetailCoordinator: BaseCoordinator {
    
    // MARK: - Properties
    
    private let coin: CoinModel
    
    // MARK: - Init
    
    /// Инициализатор координатора подробностей о монете.
    /// - Parameters:
    ///   - navigationController: Навигационный контроллер, в который будет помещён экран.
    ///   - coin: Модель выбранной монеты.
    init(navigationController: UINavigationController, coin: CoinModel) {
        self.coin = coin
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = CoinDetailViewController(coin: coin)
        navigationController.pushViewController(vc, animated: true)
    }
}

