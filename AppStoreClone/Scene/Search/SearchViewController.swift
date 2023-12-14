//
//  SearchViewController.swift
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
import RxDataSources
import RxViewController

class SearchViewController: UIViewController, ReactorKit.View {
    
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
    
    let emptyView = UIView().then {
        $0.isHidden = true
    }
    
    let noResultLabel = UILabel().then {
        $0.text = "결과 없음"
        $0.font = UIFont.systemFont(ofSize: 30, weight: .bold)
    }
    
    let noResultKeywordLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .gray
    }
    
    let loadingView = UIActivityIndicatorView().then {
        $0.isHidden = true
        $0.backgroundColor = .gray
    }
    
    var items: [String] = []
    
    lazy var datasoure = self.createDataSource()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        self.navigationItem.title = "검색"
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        subviews()
        setConstraints()
        
        // TODO: ReuseableCell 적용해보기
        // TODO: 검색어 변경시 최근 검색어 구현.
        tableview.register(AppListTableViewCell.self, forCellReuseIdentifier: "cell")
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell2")
        tableview.rx.setDelegate(self)
            .disposed(by: disposeBag)
        self.reactor?.action.onNext(.fetchRecentKeywords)
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
    
    func bind(reactor: SearchViewReactor) {
        
//        self.rx.viewWillAppear
//            .take(1)
//            .map { _ in Reactor.Action.fetchRecentKeywords }
//            .bind(to: reactor.action)  // SIGABORT 에러 남.
//            .disposed(by: disposeBag)
        

        // Action
        searchController.searchBar.rx.text
            .map { Reactor.Action.searchKeywordChanged($0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
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
                
        searchController.searchBar.rx.cancelButtonClicked
            .map { Reactor.Action.cancelButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableview.rx.itemSelected
                .map { Reactor.Action.selectCell($0.row) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        
        self.datasoure.titleForHeaderInSection = { datasource, index in
            return datasource.sectionModels[index].header
        }
        // State
//        reactor.state
//            .map { $0.appinfos }
//            // TODO: RxDataSource 공부 리펙토링 해보기
//            .bind(to: tableview.rx.items(cellIdentifier: "cell", cellType: AppListTableViewCell.self)) { (indexPath, element, cell) in
//                cell.configure(element)
//            }
//            .disposed(by: disposeBag)
        reactor.state
            .map { $0.section }
            .distinctUntilChanged()
            .bind(to: tableview.rx.items(dataSource: self.datasoure))
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$selectedInfo)
            .compactMap{ $0 }
            .subscribe { [weak self] entity in
                DispatchQueue.main.async {
                    self?.emptyView.isHidden = true
                    let detailViewController = AppRounter.detail(appInfo: entity).viewController
                    self?.navigationController?.pushViewController(detailViewController, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.resultValue }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isResultCountZero, keyword in
                self?.noResultKeywordLabel.text = "'\(keyword)'"
                self?.emptyView.isHidden = !isResultCountZero
            }.disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
                isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
            }.disposed(by: disposeBag)
    }
    
    private func subviews() {
        self.view.addSubview(tableview)
        
        self.view.addSubview(emptyView)
        self.emptyView.addSubview(noResultLabel)
        self.emptyView.addSubview(noResultKeywordLabel)
        self.view.addSubview(loadingView)
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
        
        emptyView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        noResultLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        noResultKeywordLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(noResultLabel.snp.bottom).offset(10)
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
    }
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.datasoure[indexPath.section].identity {
        case .items:
            return 352
        case .keyword:
            return 48
        }
    }
}

extension SearchViewController {
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<SearchSection> {
        return .init(
            configureCell: { _, tableview, indexPath, sectionItem in
                switch sectionItem {
                case let .searchItem(entity):
                    guard let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AppListTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.configure(entity)
                    return cell
                case let .recentKeyword(keyword):
                    let cell = tableview.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
                    cell.textLabel?.text = keyword
                    return cell
                }
            }
        )
    }
}
