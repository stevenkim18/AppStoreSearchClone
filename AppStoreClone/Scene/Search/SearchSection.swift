//
//  SearchSection.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/12/07.
//

import RxDataSources

struct SearchSection: Hashable {
    enum Identity: String {
        case items
    }
    var identity: Identity
    var items: [Item]
}

extension SearchSection: SectionModelType {
//    typealias Item = AppInfoEntity
    
//    init(original: Self, items: [Item]) {
//        self = original
//        self.items = items
//    }
    init(original: Self, items: [Item]) {
        self = SearchSection(identity: original.identity, items: items)
    }
}

extension SearchSection {
    enum Item: Hashable {
        case searchItem(AppInfoEntity)
    }
}

extension SearchSection.Item: IdentifiableType {
    var identity: String {
        return "\(self.hashValue)"
    }
}
