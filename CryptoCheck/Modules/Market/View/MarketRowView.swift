//
//  MarketRowView.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 17.08.2025.
//

import UIKit
import SnapKit

final class MarketRowView: UIStackView {
    
    // MARK: - Constants
    
    private enum Layout {
        static let numberWidth: CGFloat = 30
        static let nameWidth: CGFloat = 120
        static let priceWidth: CGFloat = 80
        static let changeWidth: CGFloat = 60
        static let marketCapWidth: CGFloat = 100
        static let spacing: CGFloat = 4
    }
    
    // MARK: - Properties
    let numberLabel = UILabel()
    let nameLabel = UILabel()
    let priceLabel = UILabel()
    let changeLabel = UILabel()
    let marketCapLabel = UILabel()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = Layout.spacing
        
        setupLabels()
        setupConstraints()
    }
    
    private func setupLabels() {
        [numberLabel, nameLabel, priceLabel, changeLabel, marketCapLabel].forEach {
            $0.font = .systemFont(ofSize: 14)
            $0.numberOfLines = 1
            $0.textAlignment = .center
            addArrangedSubview($0)
        }
    }
    
    private func setupConstraints() {
        numberLabel.snp.makeConstraints { $0.width.equalTo(Layout.numberWidth) }
        nameLabel.snp.makeConstraints { $0.width.equalTo(Layout.nameWidth) }
        priceLabel.snp.makeConstraints { $0.width.equalTo(Layout.priceWidth) }
        changeLabel.snp.makeConstraints { $0.width.equalTo(Layout.changeWidth) }
        marketCapLabel.snp.makeConstraints { $0.width.equalTo(Layout.marketCapWidth) }
    }
}
