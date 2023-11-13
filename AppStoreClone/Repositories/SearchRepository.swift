//
//  SearchRepository.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/13.
//

import Foundation
import RxSwift

protocol SearchRepositoryImpl {
    func searchAppInfos(keyword: String) -> Observable<AppInfoResultEntity>
}

final class SearchRepository: SearchRepositoryImpl {
    
    private let network = Networking()
    
    func searchAppInfos(keyword: String) -> Observable<AppInfoResultEntity> {
        return network.request(HomeApi.fetchAppsInfo(keyword))
            .asObservable()
    }
}
