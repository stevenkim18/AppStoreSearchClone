//
//  SearchSection.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/12/07.
//

import RxDataSources

struct SearchSection: Hashable {
    enum Identity: Int {
        case items = 0
        case keyword = 1
    }
    var header: String
    var identity: Identity
    var items: [Item]
}

extension SearchSection: SectionModelType {
    init(original: Self, items: [Item]) {
        self = original
        self.items = items
//        self = SearchSection(header: "", identity: original.identity, items: items)
    }
}

extension SearchSection {
    enum Item: Hashable {
        case searchItem(AppInfoEntity)
        case recentKeyword(String)
    }
}

extension SearchSection.Item: IdentifiableType {
    var identity: String {
        return "\(self.hashValue)"
    }
}
