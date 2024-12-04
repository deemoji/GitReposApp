//
//  StorageManager.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 01.12.2024.
//

import Foundation
import Combine


protocol StorageManager {

    
    func favoriteIds() -> AnyPublisher<Set<Int>, Error>
    func deletedIds() -> AnyPublisher<Set<Int>, Error>
    
    func saveDeletedId(_ id: Int)  -> AnyPublisher<Void, Error>
    func saveFavoriteId(_ id: Int) -> AnyPublisher<Void, Error>
    func removeFavoriteId(_ id: Int) ->AnyPublisher<Void, Error>
    
}

final class RealmStorageManager: StorageManager {
    
    private let storage: StorageService
    private var response: StorageResponse
    
    init(storage: StorageService) {
        self.storage = storage
        let result = storage.fetch(StorageResponse.self)
        switch result {
        case .success(let responce):
            self.response = responce.first ?? StorageResponse()
        case .failure(let error):
            fatalError(error.localizedDescription)
        }
    }
    
    
    func favoriteIds() -> AnyPublisher<Set<Int>, Error> {
        var ids = Set<Int>()
        response.favoriteIds.forEach {
            ids.insert($0)
        }
        return Just(ids).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func deletedIds() -> AnyPublisher<Set<Int>, Error> {
        var ids = Set<Int>()
        response.deletedIds.forEach {
            ids.insert($0)
        }
        return Just(ids).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func saveDeletedId(_ id: Int) -> AnyPublisher<Void, Error> {
        response.deletedIds.insert(id)
        let result = storage.saveOrUpdate(response)
        switch result {
        case .success:
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(outputType: Void.self, failure: error).eraseToAnyPublisher()
        }
    }
    
    func saveFavoriteId(_ id: Int) -> AnyPublisher<Void, Error> {
        response.favoriteIds.insert(id)
        let result = storage.saveOrUpdate(response)
        switch result {
        case .success:
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(outputType: Void.self, failure: error).eraseToAnyPublisher()
        }
    }
    
    func removeFavoriteId(_ id: Int) -> AnyPublisher<Void, Error> {
        response.favoriteIds.remove(id)
        let result = storage.saveOrUpdate(response)
        switch result {
        case .success:
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        case .failure(let error):
            return Fail(outputType: Void.self, failure: error).eraseToAnyPublisher()
        }
    }
}
