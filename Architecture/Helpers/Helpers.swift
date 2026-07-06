//
//  Helpers.swift
//  Architecture
//
//  Created by Mahipal Singh on 06/07/26.
//

import SwiftUI

struct ProductArrary: Codable {
    let products: [Product]
}
struct Product: Codable, Identifiable {
    let id: Int
    let title: String
}

import SwiftUI
protocol DataService {
    func getProduct() async throws -> [Product]
}


struct MockDataService: DataService {
    func getProduct() async throws -> [Product] {
        guard let url = URL(string: "https://dummyjson.com/products") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let products = try JSONDecoder().decode(ProductArrary.self, from: data)
        return products.products
    }
}
