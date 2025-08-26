//
//  CryptoCategory.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 01.08.2025.
//

enum MarketCategory: CaseIterable {
    case top100, defi, nft, metaverse, ai, gaming
    
    var title: String {
        switch self {
        case .top100: return "Top 100"
        case .defi: return "DeFi"
        case .nft: return "NFT"
        case .metaverse: return "Metaverse"
        case .ai: return "AI & Big Data"
        case .gaming: return "Gaming"
        }
    }
    
    var categoryId: String? {
        switch self {
        case .top100: return nil
        case .defi: return "decentralized-finance-defi"
        case .nft: return "non-fungible-tokens-nft"
        case .metaverse: return "metaverse"
        case .ai: return "artificial-intelligence"
        case .gaming: return "gaming"
        }
    }
}
