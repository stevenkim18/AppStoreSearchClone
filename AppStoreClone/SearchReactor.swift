//
//  SearchReactor.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/10/31.
//

import Foundation
import ReactorKit
import RxSwift

final class SearchReactor: Reactor {
    
    let network = Networking()
    
    enum Action {
        case searchKeyboardClicked(String)
    }
    
    enum Mutation {
        case addKeyword(String)         // 로컬 디비에 최근 검색어 저장
        case addAppInfo([AppInfoEntity])
    }
    
    struct State {
        var recentKeywords: [String] = [] // 검색어 로컬 db로 부터 불러와야 함.
        var appinfos: [AppInfoEntity] = []
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .searchKeyboardClicked(keyword):
            return fetchAppsInfos(keyword: keyword)
                .flatMap { Observable.just(Mutation.addAppInfo($0.results)) }
                .catch { _ in .empty() }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .addKeyword(keyword):
            var newState = state
            newState.recentKeywords.append(keyword)
            return newState
        case let.addAppInfo(entity):
            var newState = state
            newState.appinfos = entity
            return newState
        }
    }
    
}

extension SearchReactor {
    private func fetchAppsInfos(keyword: String) -> Observable<AppInfoResultEntity> {
        return network.request(HomeApi.fetchAppsInfo(keyword))
            .asObservable()
    }
}
