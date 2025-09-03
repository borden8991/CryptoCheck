//
//  NewsViewController.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 25.08.2025.
//

import UIKit
import SnapKit

final class NewsViewController: LocalizedViewController {
    
    // MARK: - Properties
    
    var onArticleSelected: ((URL) -> Void)?
    
    private let tableView: UITableView = {
        let t = UITableView()
        t.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifier)
        t.rowHeight = 120
        t.separatorInset = .zero
        return t
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.hidesWhenStopped = true
        return v
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private let viewModel = NewsViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        bindViewModel()
        viewModel.fetchNews(initial: true)
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = true
        
        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            DispatchQueue.main.async {
                switch state {
                case .idle:
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    
                case .loading:
                    self.activityIndicator.startAnimating()
                    
                case .refreshing:
                    break
                    
                case .error(let message):
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
        
        viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshTriggered() {
        viewModel.fetchNews(refresh: true)
    }
    
    // MARK: - Language
    
    override func applyLocalizedText() {
        super.applyLocalizedText()
        title = "news_news".localized()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell else { return UITableViewCell() }
        cell.configure(with: viewModel.article(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = viewModel.article(at: indexPath.row)
        guard let s = article.link, let url = URL(string: s) else { return }
        onArticleSelected?(url) 
    }
}
