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
}

