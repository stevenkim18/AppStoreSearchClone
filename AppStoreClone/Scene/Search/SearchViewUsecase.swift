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
    let repository = SearchRepository()
    
    func searchAppInfos(keyword: String) -> Observable<AppInfoResultEntity> {
        return repository.searchAppInfos(keyword: keyword)
    }
}
