//
//  NewsViewModel.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 25.08.2025.
//

import Foundation

enum LoadingState {
    case idle
    case loading        // initial load
    case refreshing     // pull-to-refresh
    case error(String)
}

final class NewsViewModel {
    
    // MARK: - Properties
    
    private(set) var articles: [NewsArticle] = [] {
        didSet { onUpdate?() }
    }
    
    // MARK: - Callbacks
    
    var onUpdate: (() -> Void)?
    var onError: (() -> Void)?
    var onStateChange: ((LoadingState) -> Void)?
    
    // MARK: - Public API
    
    func numberOfItems() -> Int { articles.count }
    func article(at index: Int) -> NewsArticle { articles[index] }
    
    /// Универсальный метод для загрузки новостей
    func fetchNews(initial: Bool = false, refresh: Bool = false) {
        if initial {
            onStateChange?(.loading)
        } else if refresh {
            onStateChange?(.refreshing)
        }
        
        NetworkService.shared.fetchNews { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let items):
                    self.articles = items
                    self.onStateChange?(.idle)
                case .failure(let error):
                    self.onStateChange?(.error(error.localizedDescription))
                }
            }
        }
    }
}
