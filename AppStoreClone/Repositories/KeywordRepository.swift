//
//  KeywordRepository.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/12/12.
//

import Foundation

protocol KeywordRepository {
    func fetchKeywords() -> [String]
    func addKeyword(_ keyword: String)
}

final class KeywordRepositoryImpl: KeywordRepository {
    private let userDefaults: UserDefaultsUtil
    
    init(userDefaults: UserDefaultsUtil) {
        self.userDefaults = userDefaults
    }
    
    func fetchKeywords() -> [String] {
        return userDefaults.getKeywords()
    }
    
    func addKeyword(_ keyword: String) {
        var currentKeywords = fetchKeywords()
        currentKeywords.insert(keyword, at: 0)
        let uniqueKeywords = Set(currentKeywords)
        userDefaults.setKeywords(Array(uniqueKeywords))
    }
}
