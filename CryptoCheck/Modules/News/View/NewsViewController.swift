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
        let table = UITableView()
        table.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifier)
        table.rowHeight = 120
        table.separatorInset = .zero
        return table
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        return view
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private let viewModel = NewsViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        bindViewModel()
        self.viewModel.fetchNews(initial: true)
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(self.tableView)
        view.addSubview(self.activityIndicator)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.alwaysBounceVertical = true
        
        self.refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
    }
    
    private func setupLayout() {
        self.tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bindViewModel() {
        self.viewModel.onStateChange = { [weak self] state in
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
        
        self.viewModel.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshTriggered() {
        self.viewModel.fetchNews(refresh: true)
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
        self.viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell else { return UITableViewCell() }
        cell.configure(with: self.viewModel.article(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = self.viewModel.article(at: indexPath.row)
        guard let s = article.link, let url = URL(string: s) else { return }
        self.onArticleSelected?(url)
    }
}
