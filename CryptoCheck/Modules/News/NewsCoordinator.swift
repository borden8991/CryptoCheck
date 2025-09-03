//
//  NewsCoordinator.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 02.09.2025.
//

import UIKit
import SafariServices

final class NewsCoordinator: BaseCoordinator {
    override func start() {
        let vc = NewsViewController()
        vc.title = "tab_news".localized()
        vc.onArticleSelected = { [weak self] url in
            self?.openArticle(url: url)
        }
        navigationController.setViewControllers([vc], animated: false)
    }
    
    private func openArticle(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        navigationController.present(safariVC, animated: true)
    }
}
