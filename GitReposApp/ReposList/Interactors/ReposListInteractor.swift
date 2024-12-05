//
//  ReposListInteractor.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 01.12.2024.
//

import Foundation
import Combine

protocol ReposListInteractor {
    func switchFilter(_ filter: ReposFilter)
    func nextRepos() -> AnyPublisher<[Repository], Error>
    func saveFavorite(withId id: Int) -> AnyPublisher<Void, Error>
    func removeFavorite(withId id: Int) -> AnyPublisher<Void, Error>
    func setDeleted(withId id: Int) -> AnyPublisher<Void, Error>
}

final class ReposListInteractorImpl: ReposListInteractor {
    
    let remoteManager: RemoteManager
    let storageManager: StorageManager
    
    private let query = "Swift"
    private(set) var currentPage = 1
    private(set) var currentFilter: ReposFilter = .mostStars
    
    init(_ remoteManager: RemoteManager, _ storageManager: StorageManager) {
        self.remoteManager = remoteManager
        self.storageManager = storageManager
    }
    
    func switchFilter(_ filter: ReposFilter) {
        remoteManager.cancel()
        currentFilter = filter
        currentPage = 1
    }
    
    func nextRepos() -> AnyPublisher<[Repository], Error> {
        remoteManager
            .repos(query: query, page: currentPage, filter: currentFilter)
            .zip(storageManager.deletedIds(), storageManager.favoriteIds())
            .map { [weak self] remoteRepos, deletedIds, favoriteIds in
            guard let self = self else { return [] }
            self.currentPage += 1
            return remoteRepos.compactMap { repo -> Repository? in
                guard !deletedIds.contains(repo.id) else { return nil }
                
                var newRepo = Repository(
                    id: repo.id,
                    name: repo.full_name,
                    details: repo.description ?? "",
                    userImageUrl: repo.owner.avatar_url
                )
                if favoriteIds.contains(newRepo.id) {
                    newRepo.isFavorite = true
                }
                return newRepo
            }
        }
        .eraseToAnyPublisher()
    }
    
    func saveFavorite(withId id: Int) -> AnyPublisher<Void, Error> {
        return storageManager.saveFavoriteId(id)
    }
    
    func removeFavorite(withId id: Int) -> AnyPublisher<Void, Error> {
        return storageManager.removeFavoriteId(id)
    }
    func setDeleted(withId id: Int) -> AnyPublisher<Void, Error> {
        
        return storageManager.saveDeletedId(id)
            .zip(storageManager.removeFavoriteId(id)).map { _ in
                return ()
            }.eraseToAnyPublisher()
    }
    
}
