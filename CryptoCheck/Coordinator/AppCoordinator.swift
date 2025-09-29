//
//  AppCoordinator.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 28.08.2025.
//

import UIKit

final class AppCoordinator: BaseCoordinator {
    private let window: UIWindow
    private let tabBarCoordinator: TabBarCoordinator
    
    init(window: UIWindow,
         tabBarCoordinator: TabBarCoordinator = TabBarCoordinator(tabBarController: TabBarController())) {
        self.window = window
        self.tabBarCoordinator = tabBarCoordinator
        super.init(navigationController: UINavigationController())
    }
    
    override func start() {
        
        self.tabBarCoordinator.start()
        store(self.tabBarCoordinator)
        
        window.rootViewController = self.tabBarCoordinator.tabBarController
        
        ThemeManager.shared.applyTheme(ThemeManager.shared.isDarkMode)
        window.makeKeyAndVisible()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleThemeChange),
                                               name: ThemeManager.didChange,
                                               object: nil)
    }
    
    @objc private func handleThemeChange() {
        ThemeManager.shared.applyTheme(ThemeManager.shared.isDarkMode)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ThemeManager.didChange, object: nil)
    }
}
