//
//  MarketCell.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 31.07.2025.
//

import UIKit
import SnapKit

final class MarketCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static let identifier = "MarketCell"
    
    // MARK: - Properties
    
    private let numberLabel = MarketCell.makeLabel(fontWeight: .regular, alignment: .center)
    private let nameLabel = MarketCell.makeLabel(fontWeight: .medium, alignment: .center)
    private let priceLabel = MarketCell.makeLabel(fontWeight: .regular, alignment: .right)
    private let changeLabel = MarketCell.makeLabel(fontWeight: .regular, alignment: .right)
    private let marketCapLabel = MarketCell.makeLabel(fontWeight: .regular, alignment: .right)
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        contentView.addSubview(numberLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(changeLabel)
        contentView.addSubview(marketCapLabel)
        
        numberLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(30).priority(.low)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(numberLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(50).priority(.low)
        }
        
        priceLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(80).priority(.low)
        }
        
        changeLabel.snp.makeConstraints {
            $0.leading.equalTo(priceLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(60).priority(.low)
        }
        
        marketCapLabel.snp.makeConstraints {
            $0.leading.equalTo(changeLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configure
    
    func configure(with model: CoinModel, price: Double, index: Int, currencyMode: CurrencyMode) {
        numberLabel.text = "\(index)"
        nameLabel.text = model.symbol.uppercased()
        
        priceLabel.text = currencyMode == .usd
        ? String(format: "%.2f", price)
        : String(format: "%.6f", price)
        
        if let change = model.priceChangePercentage24H {
            let isColorBlindMode = UserDefaults.standard.bool(forKey: "isColorBlindMode")
            
            let color: UIColor = change >= 0
            ? (isColorBlindMode ? .systemBlue : .systemGreen)
            : .systemRed
            
            changeLabel.text = String(format: "%.2f%%", change)
            changeLabel.textColor = color
        } else {
            changeLabel.text = "-"
            changeLabel.textColor = .secondaryLabel
        }
        marketCapLabel.text = "\(model.marketCap) $"
    }
}

// MARK: - Factory

private extension MarketCell {
    static func makeLabel(fontWeight: UIFont.Weight, alignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: fontWeight)
        label.textAlignment = alignment
        return label
    }
}
