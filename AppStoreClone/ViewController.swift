//
//  ViewController.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/10/30.
//

import UIKit
import SnapKit
import Then

class ViewController: UIViewController {
    
    let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .gray
    }
    
    let rightbarImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        self.navigationItem.title = "검색"
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "게임, 앱, 스토리 등 "
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        subviews()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func subviews() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setConstraints() {
        
        scrollView.snp.makeConstraints {
            $0.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.height.equalTo(scrollView.snp.height).multipliedBy(2)
        }
        
        // navigationBar LargeTitle right view
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        guard let UINavigationBarLargeTitleView = NSClassFromString("_UINavigationBarLargeTitleView") else {
            return
        }
        
        for view in navigationBar.subviews {
            if view.isKind(of: UINavigationBarLargeTitleView.self) {
                view.addSubview(rightbarImageView)
                rightbarImageView.snp.makeConstraints { make in
                    make.bottom.equalTo(view.snp.bottom).inset(10)
                    make.trailing.equalTo(view.snp.trailing).inset(view.directionalLayoutMargins.trailing)
                    make.width.equalTo(rightbarImageView.snp.height)
                    make.height.equalTo(40)
                }
                break
            }
        }
    }
    
}
