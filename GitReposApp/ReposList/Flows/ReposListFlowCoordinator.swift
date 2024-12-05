//
//  ReposListFlowCoordinator.swift
//  GitReposApp
//
//  Created by Дмитрий Мартьянов on 03.12.2024.
//

import Foundation
import UIKit

final class ReposListFlowCoordinator {
    
    let navigationController: UINavigationController
    let dependencies: ReposSceneDIContainer

    var reposListVC: ReposListViewController?
     
    init(navigationController: UINavigationController, dependencies: ReposSceneDIContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let vc = dependencies.makeReposListViewController()
        navigationController.pushViewController(vc, animated: true)
        reposListVC = vc
    }
}
