//
//  NewsViewModel.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 25.08.2025.
//

import Foundation

protocol NewsServiceProtocol {
    func fetchNews(page: String?, completion: @escaping (Result<[NewsArticle], Error>) -> Void)
}

enum LoadingState {
    case idle
    case loading
    case refreshing
    case error(String)
}

final class NewsViewModel {
    
    // MARK: - Properties
    
    private let service: NewsServiceProtocol
    
    private(set) var articles: [NewsArticle] = [] {
        didSet { onUpdate?() }
    }
    
    init(service: NewsServiceProtocol = NetworkService.shared) {
        self.service = service
    }
    
    // MARK: - Callbacks
    
    var onUpdate: (() -> Void)?
    var onStateChange: ((LoadingState) -> Void)?
    
    // MARK: - Public API
    
    func article(at index: Int) -> NewsArticle { articles[index] }
    
    func fetchNews(initial: Bool = false, refresh: Bool = false) {
        if initial {
            onStateChange?(.loading)
        } else if refresh {
            onStateChange?(.refreshing)
        }
        
        service.fetchNews(page: nil) { [weak self] result in
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
