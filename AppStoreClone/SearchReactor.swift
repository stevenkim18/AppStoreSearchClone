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
    enum Action {
        case searchKeyboardClicked(String)
    }
    
    enum Mutation {
        case addKeyword(String)
    }
    
    struct State {
        var recentKeywords: [String] = ["", "", ""]
    }
    
    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .searchKeyboardClicked(keyword):
            return Observable.just(Mutation.addKeyword(keyword))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .addKeyword(keyword):
            var newState = state
            newState.recentKeywords.append(keyword)
            return newState
        }
    }
    
}
