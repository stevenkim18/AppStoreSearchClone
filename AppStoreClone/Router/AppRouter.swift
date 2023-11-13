//
//  AppRouter.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/13.
//

import UIKit

enum AppRounter {
    case search
    case detail(appInfo: AppInfoEntity)
}

extension AppRounter {
    var viewController: UIViewController {
        switch self {
        case .search:
            return searchBuilder()
        case let .detail(appInfo):
            return detailBuilder(appInfo: appInfo)
        }
    }
}

private func searchBuilder() -> UIViewController {
    let network = Networking()
    let repository = SearchRepository(network: network)
    let usecase = SearchViewUsecase(repository: repository)
    let reactor = SearchViewReactor(usecase: usecase)
    let viewController = SearchViewController()
    viewController.reactor = reactor
    let navigationController = UINavigationController(rootViewController: viewController)
    navigationController.navigationBar.prefersLargeTitles = true
    return navigationController
}

private func detailBuilder(appInfo: AppInfoEntity) -> UIViewController {
    let viewController = DetailViewController(appinfo: appInfo)
    return viewController
}
