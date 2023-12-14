//
//  SearchRepository.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/13.
//

import Foundation
import RxSwift

protocol SearchRepository {
    func searchAppInfos(keyword: String) -> Observable<AppInfoResultEntity>
}

final class SearchRepositoryImpl: SearchRepository {
    
    private let network: NetworkingProtocol
    
    init(network: NetworkingProtocol) {
        self.network = network
    }
    
    func searchAppInfos(keyword: String) -> Observable<AppInfoResultEntity> {
        return network.request(HomeApi.fetchAppsInfo(keyword))
            .asObservable()
    }
}
