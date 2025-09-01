//
//  CryptoModel.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 31.07.2025.
//

import Foundation

struct CoinModel: Decodable {
    
    let id: String
    let symbol: String
    let name: String
    let currentPrice: Double
    let circulatingSupply: Double
    let priceChangePercentage24H: Double?
    let marketCap: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case currentPrice = "current_price"
        case circulatingSupply = "circulating_supply"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCap = "market_cap"
    }
}
