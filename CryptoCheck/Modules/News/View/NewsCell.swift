//
//  NewsCell.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 25.08.2025.
//

import UIKit
import SnapKit

final class NewsCell: UITableViewCell {
    
    //MARK: - Constants
    
    static var identifier: String {
        String(describing: self)
    }
    
    //MARK: - Private properties
    
    private var currentImageUrl: URL?
    
    private let thumbImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 8
        image.image = UIImage(systemName: "photo")
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
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
        currentImageUrl = nil
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.addSubview(thumbImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(sourceLabel)
        
        thumbImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 120, height: 120))
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
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.trailing.equalTo(titleLabel)
        }
        
        sourceLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(3)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }
    
    // MARK: - Configure
    
    func configure(with article: NewsArticle) {
        titleLabel.text = article.title
        subtitleLabel.text = article.description
        sourceLabel.text = "Source: \(article.sourceId)"
        
        if let urlStr = article.imageUrl, let url = URL(string: urlStr) {
            currentImageUrl = url
            loadImage(url: url)
        } else {
            thumbImageView.image = UIImage(systemName: "photo")
            currentImageUrl = nil
        }
    }
    
    //MARK: - Private methods
    
    private func loadImage(url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                if self.currentImageUrl == url {
                    self.thumbImageView.image = image
                }
            }
        }.resume()
    }
}
