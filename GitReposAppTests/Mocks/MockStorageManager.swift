//
//  StorageManager.swift
//  GitReposAppTests
//
//  Created by Дмитрий Мартьянов on 04.12.2024.
//

import Foundation
import Combine
@testable import GitReposApp

final class MockStorageManager: StorageManager {
    
    var response: StorageResponse = StorageResponse()
    var error: Error?
    
    func favoriteIds() -> AnyPublisher<Set<Int>, Error> {
        let ids = Set(response.favoriteIds)
        return handleError(ids)
    }
    
    func deletedIds() -> AnyPublisher<Set<Int>, Error> {
        let ids = Set(response.deletedIds)
        return handleError(ids)
    }
    
    func saveDeletedId(_ id: Int) -> AnyPublisher<Void, Error> {
        response.deletedIds.insert(id)
        return handleError(())
    }
    
    func saveFavoriteId(_ id: Int) -> AnyPublisher<Void, Error> {
        response.favoriteIds.insert(id)
        return handleError(())
    }
    
    func removeFavoriteId(_ id: Int) -> AnyPublisher<Void, Error> {
        response.favoriteIds.remove(id)
        return handleError(())
    }
    
    private func handleError<T>(_ value: T) -> AnyPublisher<T, Error> {
        if let error {
            return Fail(outputType: T.self, failure: error)
                .eraseToAnyPublisher()
        } else {
            return Just(value)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
}

