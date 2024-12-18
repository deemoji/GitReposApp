//
//  AppDIContainer.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 03.12.2024.
//

import Foundation
import RealmSwift

final class AppDIContainer {
    
    var networkService: NetworkService = NetworkServiceImpl()
    var storageService: StorageService = RealmStorageService(configuration:  .defaultConfiguration)
    var imageLoader: ImageLoader = ImageLoaderImpl()
    
    func makeReposSceneDIContainer() -> ReposSceneDIContainer {
        return ReposSceneDIContainer(ReposSceneDIContainer.Dependencies(
            networkService: networkService,
            storageService: storageService,
            imageLoader: imageLoader))
    }
}
