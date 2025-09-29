//
//  TabBarCoordinator.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 02.09.2025.
//

import UIKit

final class TabBarCoordinator: BaseCoordinator {
    
    let tabBarController: TabBarController
    
    private let marketNav = UINavigationController()
    private let portfolioNav = UINavigationController()
    private let searchNav = UINavigationController()
    private let newsNav = UINavigationController()
    private let profileNav = UINavigationController()
    
    init(tabBarController: TabBarController = TabBarController()) {
        self.tabBarController = tabBarController
        super.init(navigationController: UINavigationController())
    }
    
    override func start() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTabTitles),
                                               name: .languageChanged,
                                               object: nil)
        
        let marketCoordinator = MarketCoordinator(navigationController: marketNav)
        marketCoordinator.start()
        store(marketCoordinator)
        
        let portfolioCoordinator = PortfolioCoordinator(navigationController: portfolioNav)
        portfolioCoordinator.start()
        store(portfolioCoordinator)
        
        let searchCoordinator = SearchCoordinator(navigationController: searchNav)
        searchCoordinator.start()
        store(searchCoordinator)
        
        let newsCoordinator = NewsCoordinator(navigationController: newsNav)
        newsCoordinator.start()
        store(newsCoordinator)
        
        let profileCoordinator = ProfileCoordinator(navigationController: profileNav)
        profileCoordinator.start()
        store(profileCoordinator)
        
        self.marketNav.tabBarItem = UITabBarItem(title: "tab_market".localized(),
                                            image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
                                            tag: 0)
        self.portfolioNav.tabBarItem = UITabBarItem(title: "tab_portfolio".localized(),
                                               image: UIImage(systemName: "briefcase"),
                                               tag: 1)
        self.searchNav.tabBarItem = UITabBarItem(title: "tab_search".localized(),
                                            image: UIImage(systemName: "magnifyingglass"),
                                            tag: 2)
        self.newsNav.tabBarItem = UITabBarItem(title: "tab_news".localized(),
                                          image: UIImage(systemName: "square.grid.2x2"),
                                          tag: 3)
        self.profileNav.tabBarItem = UITabBarItem(title: "tab_profile".localized(),
                                             image: UIImage(systemName: "person"),
                                             tag: 4)
        
        self.tabBarController.setViewControllers([marketNav,
                                             portfolioNav,
                                             searchNav,
                                             newsNav,
                                             profileNav],
                                            animated: false)
    }
    
    @objc private func updateTabTitles() {
        self.marketNav.tabBarItem.title = "tab_market".localized()
        self.portfolioNav.tabBarItem.title = "tab_portfolio".localized()
        self.searchNav.tabBarItem.title = "tab_search".localized()
        self.newsNav.tabBarItem.title = "tab_news".localized()
        self.profileNav.tabBarItem.title = "tab_profile".localized()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
}
