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
    
    private let usecase: SearchViewUsecaseProtocol
    
    enum Action: Equatable {
        case searchKeywordChanged(String)
        case searchKeyboardClicked(String)
        case cancelButtonClicked
        case selectCell(Int)
        case fetchRecentKeywords
    }
    
    enum Mutation {
        case addKeyword(String)         // 로컬 디비에 최근 검색어 저장
        case addAppInfo([AppInfoEntity])
        case setAppItem(AppInfoEntity)
        case setSearchResult(Bool, String)
        case setRecentKeywords([String])
        case isLoading(Bool)
    }
    
    struct State {
        var recentKeywords: [String] = [] // 검색어 로컬 db로 부터 불러와야 함.
        var appinfos: [AppInfoEntity] = []
        @Pulse var selectedInfo: AppInfoEntity?
        var resultValue: (isResultCountZero: Bool, keyword: String) = (false, "")
        var isLoading: Bool = false
//        var isResultCountZero: Bool = false
        var section: [SearchSection] = [.init(header: "", identity: .items, items: [])]
    }
    
    var initialState: State = State()
    
    init(usecase: SearchViewUsecaseProtocol) {
        self.usecase = usecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .searchKeywordChanged(keyword):
            print(keyword)
            return Observable.empty()
        case let .searchKeyboardClicked(keyword):
            usecase.addKeyword(keyword)
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
        case .cancelButtonClicked, .fetchRecentKeywords:
            var keywords = usecase.fetchKeyword()
            keywords.append(contentsOf: ["가나다", "마바사", "아자차", "타파하"])
            return Observable.just(Mutation.setRecentKeywords(keywords))
        case let.selectCell(row):
//            let item = self.currentState.appinfos[row]
            let selectedItem = self.currentState.section[0].items[row]
            switch selectedItem {
            case let .searchItem(entity):
                return Observable.just(Mutation.setAppItem(entity))
            case .recentKeyword:
                return Observable.empty()
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .addKeyword(keyword):
            var newState = state
            newState.recentKeywords.append(keyword)
            return newState
        case let .addAppInfo(entitys):
            var newState = state
//            newState.selectedInfo = nil
//            newState.appinfos = entity
            let items: [SearchSection.Item] = entitys.map { entity in
                SearchSection.Item.searchItem(entity)
            }
            let section: SearchSection = .init(header: "", identity: .items, items: items)
            newState.section[0] = section
            return newState
        case let .setAppItem(entity):
            var newState = state
            newState.selectedInfo = entity
            return newState
        case let .setSearchResult(isResultCountZero, keyword):
            var newState = state
            newState.resultValue = (isResultCountZero, keyword)
            return newState
        case let .setRecentKeywords(keywords):
            var newState = state
            let items: [SearchSection.Item] = keywords.map { keyword in
                SearchSection.Item.recentKeyword(keyword)
            }
            let section: SearchSection = .init(header: "최근 검색어", identity: .keyword, items: items)
            newState.section[0] = section
            return newState
        case let .isLoading(isLoading):
            var newState = state
            newState.isLoading = isLoading
            return newState
        }
    }
    
}
