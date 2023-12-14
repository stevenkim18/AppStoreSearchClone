//
//  UserDefaultsUtil.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/12/12.
//

import Foundation

protocol UserDefaultsUtil {
    func getKeywords() -> [String]
    func setKeywords(_ value: [String])
}

class UserDefaultsUtilImpl: UserDefaultsUtil {
    
    private let userDefaults = UserDefaults.standard
    
    func getKeywords() -> [String] {
        return UserDefaults.standard.array(forKey: "\(UserDefaultsKeys.keywords)") as? [String] ?? []
    }
    
    func setKeywords(_ value: [String]) {
        UserDefaults.standard.set(value, forKey: "\(UserDefaultsKeys.keywords)")
    }
}

enum UserDefaultsKeys: String {
    case keywords
}

extension UserDefaultsKeys: CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
}
