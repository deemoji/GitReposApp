//
//  EndpointType.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 30.11.2024.
//

import Foundation

protocol EndpointType {
    var baseUrl: String {get}
    var path: String { get }
    var parameters: [String: Any] { get }
}

extension EndpointType {
    var components: URLComponents {
        guard var components = URLComponents(string: self.baseUrl + path) else {
            fatalError("Cant build components from \(self.baseUrl + path)")
        }
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        return components
    }
}
