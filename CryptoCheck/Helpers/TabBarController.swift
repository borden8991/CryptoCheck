//
//  TabBarController.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 17.09.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private let separator = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setupSeparator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSeparatorFrame()
    }
    
    func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    func setupSeparator() {
        separator.backgroundColor = UIColor.separator.withAlphaComponent(0.4)
        tabBar.addSubview(separator)
    }
    
    func updateSeparatorFrame() {
        separator.frame = CGRect(
            x: 0,
            y: 0,
            width: tabBar.bounds.width,
            height: 0.5
        )
    }
}
