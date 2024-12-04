//
//  ReposSceneDIContainer.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 03.12.2024.
//

import Foundation
import UIKit

final class ReposSceneDIContainer {
    struct Dependencies {
        let networkService: NetworkService
        let storageService: StorageService
        let imageLoader: ImageLoader?
    }

    private let dependencies: Dependencies

    init(_ dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func makeReposListFlowCoordinator(navigationController: UINavigationController) -> ReposListFlowCoordinator {
        return ReposListFlowCoordinator(
            navigationController: navigationController,
            dependencies: self)
    }
    
    func makeReposListViewController() -> ReposListViewController {
        ReposListViewController.create(with: makeReposListViewModel(), imageLoader: dependencies.imageLoader)
    }

    private func makeReposListViewModel() -> ReposListViewModel {
        return ReposListViewModelImpl(interactor: makeReposListInteractor())
    }
    
    private func makeReposListInteractor() -> ReposListInteractor {
        return ReposListInteractorImpl(
            makeRemoteManager(),
            makeStorageManager())
    }

    private func makeRemoteManager() -> RemoteManager {
        return GithubRemoteManager(network: dependencies.networkService)
    }

    private func makeStorageManager() -> StorageManager {
        return RealmStorageManager(storage: dependencies.storageService)
    }
    
    
}
