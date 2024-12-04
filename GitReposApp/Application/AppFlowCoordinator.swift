//
//  AppFlowCoordinator.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 03.12.2024.
//

import Foundation
import UIKit

final class AppFlowCoordinator {
    var navigationController: UINavigationController
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController, appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        let reposSceneDIContainer = appDIContainer.makeReposSceneDIContainer()
        let flow = reposSceneDIContainer.makeReposListFlowCoordinator(navigationController: navigationController)
        flow.start()
    }
}
