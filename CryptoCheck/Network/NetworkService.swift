//
//  NetworkService.swift
//  CryptoCheck
//
//  Created by Denis Borovoi on 31.07.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

final class NetworkService {
    
    // MARK: - Singleton
    
    static let shared = NetworkService()
    private init() {}
    
    // MARK: - Properties
    
    private let baseURL = "https://api.coingecko.com/api/v3"
    private let apiKey = "CG-7g5JcowMt1duvMVcDoZPkYxc"
    
    // MARK: - Helpers
    
    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "x-cg-demo-api-key")
        return request
    }
    
    // MARK: - FetchMarket
    
    func fetchMarketCoins(
        vsCurrency: String = "usd",
        completion: @escaping (Result<[CoinModel], Error>) -> Void
    ) {
        let urlString =
        "\(baseURL)/coins/markets?vs_currency=\(vsCurrency)" +
        "&order=market_cap_desc&per_page=50&page=1" +
        "&sparkline=false&price_change_percentage=24h"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let request = makeRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error { completion(.failure(error)); return }
            guard let data else { completion(.failure(NetworkError.invalidResponse)); return }
            
            do {
                let coins = try JSONDecoder().decode([CoinModel].self, from: data)
                completion(.success(coins))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    func fetchMarketCoinsByIDs(
        ids: String,
        completion: @escaping (Result<[CoinModel], Error>) -> Void
    ) {
        let urlString =
        "\(baseURL)/coins/markets?vs_currency=usd&ids=\(ids)" +
        "&order=market_cap_desc&sparkline=false&price_change_percentage=24h"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let request = makeRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error { completion(.failure(error)); return }
            guard let data else { completion(.failure(NetworkError.invalidResponse)); return }
            
            do {
                let coins = try JSONDecoder().decode([CoinModel].self, from: data)
                completion(.success(coins))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    func fetchCoinMarketChart(
        coinID: String,
        days: String,
        completion: @escaping (Result<[(Double, Double)], Error>) -> Void
    ) {
        let urlString =
        "\(baseURL)/coins/\(coinID)/market_chart?vs_currency=usd&days=\(days)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error { completion(.failure(error)); return }
            guard let data else { completion(.failure(NetworkError.invalidResponse)); return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let prices = (json?["prices"] as? [[Any]])?.compactMap { item -> (Double, Double)? in
                    guard let time = item[0] as? Double,
                          let price = item[1] as? Double else { return nil }
                    return (time, price)
                } ?? []
                completion(.success(prices))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    // MARK: - Search
    
    func fetchSearchCoins(
        query: String,
        completion: @escaping (Result<SearchResponse, Error>) -> Void
    ) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/search?query=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let request = makeRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error { completion(.failure(error)); return }
            guard let data else { completion(.failure(NetworkError.invalidResponse)); return }
            
            do {
                let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                completion(.success(searchResponse))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
}
