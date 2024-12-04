//
//  MockRemoteManager.swift
//  GitReposAppTests
//
//  Created by Дмитрий Мартьянов on 04.12.2024.
//

import Foundation
import Combine
@testable import GitReposApp

final class MockRemoteManager: RemoteManager {
    
    var response: [RemoteRepository] = []
    var error: Error?
    
    func repos(query: String, page: Int, filter: GitReposApp.ReposFilter) -> AnyPublisher<[GitReposApp.RemoteRepository], Error> {
        if let error {
            return Fail(outputType: [RemoteRepository].self, failure: error).eraseToAnyPublisher()
        } else {
            return Just(response).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
    func cancel() {
        
    }
}
