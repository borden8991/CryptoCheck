//
//  SearchModel.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 13.08.2025.
//

import Foundation

struct SearchResponse: Codable {
    let coins: [SearchCoin]
}

struct SearchCoin: Codable {
    let id: String
    let name: String
    let symbol: String
    let marketCapRank: Int?
    let thumb: String
    let large: String

    enum CodingKeys: String, CodingKey {
        case id, name, symbol
        case marketCapRank = "market_cap_rank"
        case thumb, large
    }
}
