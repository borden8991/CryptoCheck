//
//  MarketCell.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 31.07.2025.
//

import UIKit
import SnapKit
import SkeletonView

final class MarketCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static var identifier: String {
        String(describing: self)
    }
    
    // MARK: - Properties
    
    private let numberLabel = makeLabel(fontWeight: .regular, alignment: .center)
    private let nameLabel = makeLabel(fontWeight: .medium, alignment: .center)
    private let priceLabel = makeLabel(fontWeight: .regular, alignment: .right)
    private let changeLabel = makeLabel(fontWeight: .regular, alignment: .right)
    private let marketCapLabel = makeLabel(fontWeight: .regular, alignment: .right)
    
    //MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        isSkeletonable = true
        contentView.isSkeletonable = true
        [numberLabel, nameLabel, priceLabel, changeLabel, marketCapLabel].forEach {
            $0.isSkeletonable = true
        }
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
            $0.width.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(numberLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(50)
        }
        
        priceLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(80)
        }
        
        changeLabel.snp.makeConstraints {
            $0.leading.equalTo(priceLabel.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(80)
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
        
        priceLabel.text = formatPrice(price)
        
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
    
    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        
        let intPart = Int(value)
        
        if intPart >= 100 {
            formatter.maximumFractionDigits = 2
        } else if intPart >= 1 {
            formatter.maximumFractionDigits = 4
        } else {
            formatter.maximumFractionDigits = 6
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
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
