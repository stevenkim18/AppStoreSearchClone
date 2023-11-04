//
//  AppStoreCloneTests.swift
//  AppStoreCloneTests
//
//  Created by seungwooKim on 2023/10/30.
//

import XCTest
import RxTest
import RxCocoa
import RxSwift
import RxBlocking
@testable import AppStoreClone

final class AppStoreCloneTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test검색창에_검색어를_입력했을_때_액션과_검색어가_리엑터로_전달된다() {
        // Given
        let searchKeyword = "성경"
        
        let reactor = SearchReactor()
        reactor.isStubEnabled = true
        
        let viewcontroller = ViewController()
        viewcontroller.reactor = reactor
        viewcontroller.searchController.searchBar.text = searchKeyword
        
        // When
        viewcontroller.searchController.searchBar.searchTextField.sendActions(for: .editingDidEndOnExit)
        
        // Then
        XCTAssertEqual(reactor.stub.actions.last, .searchKeyboardClicked(searchKeyword))
    }
    
    func test검색어입력액션이_전달되었을_때_실제_API가_호출되고_앱정보결과값이_넣어진다() {
        let reactor = SearchReactor()
        
        let disposeBag = DisposeBag()
        
        reactor.action.onNext(.searchKeyboardClicked("성경"))
        
        guard let response = try? reactor.state.skip(1).toBlocking(timeout: 10).first() else {
            XCTFail("")
            return
        }
        
        // 초기 값은 appinfos가 빈 배열인데
        // 네크워크에 성공하면 1개 이상 값이 들어옴(지금 10개씩 받아오게 세팅해 둠)
        XCTAssertTrue(response.appinfos.count != 0)
    }
    
    func testAPI통신_결과로_앱_정보들에_대한_값들을_변경되었을_때_TableView에_잘_반영이_된다() {
        // Given
        let appInfos: [AppInfoEntity] = [AppInfoEntity.mock()]
        
        let reactor = SearchReactor()
        reactor.isStubEnabled = true
        
        let viewcontroller = ViewController()
        viewcontroller.reactor = reactor
        
        // When
        reactor.stub.state.value.appinfos = appInfos
        
        // Then
        XCTAssertEqual(viewcontroller.tableview.numberOfRows(inSection: 0), appInfos.count)
    }

}
