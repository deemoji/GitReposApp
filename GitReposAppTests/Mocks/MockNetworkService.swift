//
//  MockNetworkService.swift
//  GitReposAppTests
//
//  Created by Дмитрий Мартьянов on 30.11.2024.
//

import Foundation
@testable import GitReposApp

class MockNetworkService: NetworkService {
    var fetchResponse: Any?
    var mockedError: Error?
    
    func fetch<T>(_ endpoint: GitReposApp.EndpointType) async throws -> T where T : Decodable {
        try await Task.sleep(for: .seconds(0.2))
        if let error = mockedError {
            throw error
        }

        if let response = fetchResponse as? T {
            return response
        }
        
        throw MockError.mock
    }
    func cancel() {
        mockedError = URLError(URLError.cancelled)
    }
}
