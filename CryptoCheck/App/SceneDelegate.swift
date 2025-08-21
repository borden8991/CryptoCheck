//
//  SceneDelegate.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 31.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let tabBarVC = UITabBarController()
        
        let marketVC = UINavigationController(rootViewController: MarketViewController())
        let portfolioVC = UIViewController()
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        let overviewVC = UIViewController()
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        
        marketVC.tabBarItem = UITabBarItem(title: "Рынок",
                                           image: UIImage(systemName: "chart.line.uptrend.xyaxis"),
                                           tag: 0)
        
        portfolioVC.tabBarItem = UITabBarItem(title: "Портфель",
                                              image: UIImage(systemName: "briefcase"),
                                              tag: 1)
        
        searchVC.tabBarItem = UITabBarItem(title: "Поиск",
                                           image: UIImage(systemName: "magnifyingglass"),
                                           tag: 2)
        
        overviewVC.tabBarItem = UITabBarItem(title: "Обзор",
                                             image: UIImage(systemName: "square.grid.2x2"),
                                             tag: 3)
        
        profileVC.tabBarItem = UITabBarItem(title: "Профиль",
                                            image: UIImage(systemName: "person"),
                                            tag: 4)
        
        tabBarVC.viewControllers = [marketVC, portfolioVC, searchVC, overviewVC, profileVC]
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        window?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        
        self.window?.rootViewController = tabBarVC
        self.window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

