//
//  AppInfoEntity+.swift
//  AppStoreCloneTests
//
//  Created by seungwooKim on 2023/11/04.
//

import Foundation

@testable import AppStoreClone

extension AppInfoEntity {
    static func mock() -> Self {
        Self.init(screenshotUrls: ["", "", ""],
                  trackName: "앱 이름",
                  genres: ["도서", "게임"],
                  averageUserRating: 4.33,
                  artworkUrl100: "")
    }
}
