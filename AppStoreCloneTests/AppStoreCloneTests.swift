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

}
