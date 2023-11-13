//
//  Entitys.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/02.
//

import Foundation

struct AppInfoResultEntity: Codable {
    let resultCount: Int
    let results: [AppInfoEntity]
}

struct AppInfoEntity: Codable {
    let screenshotUrls: [String]    // 스샷 이미지 url
    let trackName: String           // 앱 이름
    let artistName: String          // 개발자 계정 이름
    let genres: [String]            // 카테고리
    let averageUserRating: Double   // 앱 평점
    let artworkUrl100: String       // 앱 아이콘 url
    let artworkUrl512: String       // 앱 아이콘 url
    let description: String         // 앱 상세 설명
}
