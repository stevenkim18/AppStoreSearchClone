//
//  ViewController.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/10/30.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

class ViewController: UIViewController, ReactorKit.View {
    
    let tableview = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let rightbarImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let searchController = UISearchController(searchResultsController: nil).then {
        $0.searchBar.placeholder = "게임, 앱, 스토리 등 "
    }
    
    var items: [String] = []
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        self.navigationItem.title = "검색"
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        subviews()
        setConstraints()
        
        tableview.register(AppListTableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    // TODO: RxViewController로 구현.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rightbarImageView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rightbarImageView.isHidden = false
    }
    
    func bind(reactor: SearchReactor) {
        // Action
        searchController.searchBar.rx.searchButtonClicked
            .map { [weak self] _ in
                guard let text = self?.searchController.searchBar.text else {
                    return Reactor.Action.searchKeyboardClicked("")
                }
                return Reactor.Action.searchKeyboardClicked(text)
            }
            .do(onNext: { [weak self] _ in
                self?.searchController.searchBar.text = ""
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableview.rx.itemSelected
                .map { Reactor.Action.selectCell($0.row) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        
        // State
        reactor.state
            .map { $0.appinfos }
            .bind(to: tableview.rx.items(cellIdentifier: "cell", cellType: AppListTableViewCell.self)) { (indexPath, element, cell) in
                cell.configure(element)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedInfo }
            .compactMap{ $0 }
            .subscribe { [weak self] entity in
                DispatchQueue.main.async {
                    let detailViewController = DetailViewController(appinfo: entity)
                    self?.navigationController?.pushViewController(detailViewController, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func subviews() {
        self.view.addSubview(tableview)
    }
    
    private func setConstraints() {
        
        tableview.snp.makeConstraints {
            $0.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        352
    }
}
