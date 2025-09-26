//
//  NewsCell.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 25.08.2025.
//

import UIKit
import SnapKit

final class NewsCell: UITableViewCell {
    
    static let identifier = "NewsCell"
    
    private var currentImageURL: URL?
    
    private let thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.image = UIImage(systemName: "photo")
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.numberOfLines = 2
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 3
        return l
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = UIImage(systemName: "photo")
        currentImageURL = nil
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.addSubview(thumbImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        thumbImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 80))
            make.leading.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbImageView.snp.top)
            make.leading.equalTo(thumbImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }
    
    // MARK: - Configure
    
    func configure(with article: NewsArticle) {
        titleLabel.text = article.title
        subtitleLabel.text = article.description
        
        if let urlStr = article.image_url, let url = URL(string: urlStr) {
            currentImageURL = url
            loadImage(url: url)
        } else {
            thumbImageView.image = UIImage(systemName: "photo")
            currentImageURL = nil
        }
    }
    
    private func loadImage(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self,
                  let data,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                // проверяем, что картинка соответствует актуальному URL для этой ячейки
                if self.currentImageURL == url {
                    self.thumbImageView.image = image
                }
            }
        }.resume()
    }
}
