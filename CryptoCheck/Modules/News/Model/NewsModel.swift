//
//  NewsModel.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 25.08.2025.
//

import Foundation

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int?
    let results: [NewsArticle]?
}

struct NewsArticle: Codable {
    let title: String
    let description: String
    let link: String?
    let pubDate: String?
    let image_url: String?
    let source_id: String
}
