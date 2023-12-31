//
//  SearchViewUsecase.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/13.
//

import RxSwift
import Foundation

protocol SearchViewUsecaseProtocol: AnyObject {
    func searchAppInfos(keyword: String) -> Observable<AppInfoResultEntity>
    func addKeyword(_ keyword: String)
    func fetchKeyword() -> [String]
    func filterMatchedKeyword(_ searchedKeyword: String) -> [String]
}

final class SearchViewUsecase: SearchViewUsecaseProtocol {
    private let searchRepository: SearchRepository
    private let keywordRepository: KeywordRepository
    
    init(searchRepository: SearchRepository, keywordRepository: KeywordRepository) {
        self.searchRepository = searchRepository
        self.keywordRepository = keywordRepository
    }
    
    func searchAppInfos(keyword: String) -> Observable<AppInfoResultEntity> {
        return searchRepository.searchAppInfos(keyword: keyword)
    }
    
    func addKeyword(_ keyword: String) {
        keywordRepository.addKeyword(keyword)
    }
    
    func fetchKeyword() -> [String] {
        return keywordRepository.fetchKeywords()
    }
    
    func filterMatchedKeyword(_ searchedKeyword: String) -> [String] {
        let keywords = fetchKeyword()
        if searchedKeyword.isEmpty { return keywords }
        return keywords.filter { $0.contains(searchedKeyword) }
    }
}
