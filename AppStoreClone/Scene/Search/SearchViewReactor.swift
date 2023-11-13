//
//  SearchReactor.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/10/31.
//

import Foundation
import ReactorKit
import RxSwift

final class SearchViewReactor: Reactor {
    
    let usecase = SearchViewUsecase()
    
    enum Action: Equatable {
        case searchKeyboardClicked(String)
        case selectCell(Int)
    }
    
    enum Mutation {
        case addKeyword(String)         // 로컬 디비에 최근 검색어 저장
        case addAppInfo([AppInfoEntity])
        case setAppItem(AppInfoEntity)
        case setSearchResult(Bool, String)
        case isLoading(Bool)
    }
    
    struct State {
        var recentKeywords: [String] = [] // 검색어 로컬 db로 부터 불러와야 함.
        var appinfos: [AppInfoEntity] = []
        @Pulse var selectedInfo: AppInfoEntity?
        var resultValue: (isResultCountZero: Bool, keyword: String) = (false, "")
        var isLoading: Bool = false
//        var isResultCountZero: Bool = false
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .searchKeyboardClicked(keyword):
            return Observable.concat([
                Observable.just(Mutation.isLoading(true)),
                usecase.searchAppInfos(keyword: keyword)
                    .flatMap {
                        if $0.resultCount == 0 {
                            return Observable.concat([
                                Observable.just(Mutation.setSearchResult(true, keyword)),
                                Observable.just(Mutation.addAppInfo([]))
                            ])
                        } else {
                            return Observable.concat([
                                Observable.just(Mutation.setSearchResult(false, keyword)),
                                Observable.just(Mutation.addAppInfo($0.results))
                            ])
                        }
                    }.catch { _ in .empty() },
                Observable.just(Mutation.isLoading(false)),
            ])
        case let.selectCell(row):
            let item = self.currentState.appinfos[row]
            return Observable.just(Mutation.setAppItem(item))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .addKeyword(keyword):
            var newState = state
            newState.recentKeywords.append(keyword)
            return newState
        case let .addAppInfo(entity):
            var newState = state
            newState.selectedInfo = nil
            newState.appinfos = entity
            return newState
        case let .setAppItem(entity):
            var newState = state
            newState.selectedInfo = entity
            return newState
        case let .setSearchResult(isResultCountZero, keyword):
            var newState = state
            newState.resultValue = (isResultCountZero, keyword)
            return newState
        case let .isLoading(isLoading):
            var newState = state
            newState.isLoading = isLoading
            return newState
        }
    }
    
}
