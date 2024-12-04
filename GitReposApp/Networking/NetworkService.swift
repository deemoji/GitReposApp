//
//  NetworkService.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 30.11.2024.
//

import Foundation

protocol NetworkService {
    func fetch<T: Decodable>(_ endpoint: EndpointType) async throws -> T
    func cancel()
}

final class NetworkServiceImpl: NetworkService {
    
    let urlSession: URLSession
    var task: URLSessionDataTask?
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func fetch<T: Decodable>(_ endpoint: EndpointType) async throws -> T {
        guard let url = endpoint.components.url, !url.absoluteString.isEmpty else {
            throw URLError(.badURL)
        }
        
        let request = URLRequest(url: url)
    
        return try await withCheckedThrowingContinuation { continuation in
            let task = urlSession.dataTask(with: request) { data, responce, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let httpResponse = responce as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode), let data else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    continuation.resume(returning: decoded)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            self.task = task
            task.resume()
        }
    }
    
    func cancel() {
        task?.cancel()
    }
    
}
