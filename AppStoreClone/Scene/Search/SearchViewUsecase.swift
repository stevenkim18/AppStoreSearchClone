//
//  SearchViewUsecase.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/13.
//

import RxSwift

protocol SearchViewUsecaseProtocol: AnyObject {
    func searchAppInfos(keyword: String) -> Observable<AppInfoResultEntity>
}

final class SearchViewUsecase: SearchViewUsecaseProtocol {
    private let repository: SearchRepositoryImpl
    
    init(repository: SearchRepositoryImpl) {
        self.repository = repository
    }
    
    func searchAppInfos(keyword: String) -> Observable<AppInfoResultEntity> {
        return repository.searchAppInfos(keyword: keyword)
    }
}
