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
import ReusableKit

class SearchViewController: UIViewController, ReactorKit.View {
    
    enum Reusable {
        static let keywordCell = ReusableCell<UITableViewCell>()
        static let appInfoCell = ReusableCell<AppListTableViewCell>()
    }
    
    // MARK: Constants
    private enum Constants {
        static let title = "검색"
        static let defaultProfileImageName = "person.circle"
        static let searchbarPlaceHolder = "게임, 앱, 스토리 등 "
        static let noResultText = "결과 없음"
    }
    
    // MARK: UI Properties
    lazy var tableview = UITableView().then {
        $0.register(Reusable.keywordCell)
        $0.register(Reusable.appInfoCell)
    }
    
    let rightbarImageView = UIImageView().then {
        $0.image = UIImage(systemName: Constants.defaultProfileImageName)
    }
    
    let searchController = UISearchController(searchResultsController: nil).then {
        $0.searchBar.placeholder = Constants.searchbarPlaceHolder
    }
    
    let emptyView = UIView().then {
        $0.isHidden = true
    }
    
    let noResultLabel = UILabel().then {
        $0.text = Constants.noResultText
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
    
    lazy var datasoure = self.createDataSource()
    
    var disposeBag = DisposeBag()
    
    // MARK: Initializing
    init(reactor: SearchViewReactor) {
        defer {
            self.reactor = reactor
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setNavigationItem()
        configureUI()
        setConstraints()
        
        tableview.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rightbarImageView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rightbarImageView.isHidden = false
    }
    
    private func configureUI() {
        self.view.addSubview(tableview)
        self.view.addSubview(emptyView)
        self.emptyView.addSubview(noResultLabel)
        self.emptyView.addSubview(noResultKeywordLabel)
        self.view.addSubview(loadingView)
    }
    
    private func setNavigationItem() {
        self.navigationItem.title = Constants.title
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setConstraints() {
        
        setNavigationContraint()
        
        tableview.snp.makeConstraints {
            $0.top.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
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
    
    private func setNavigationContraint() {
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

// MARK: ReactorBind
extension SearchViewController {
    func bind(reactor: SearchViewReactor) {
        setFetchRecentKeyword(reactor: reactor)
        bindSearchBarText(reactor: reactor)
        bindSearchBarSearchButton(reactor: reactor)
        bindSearchBarCancelButton(reactor: reactor)
        bindTableViewItem(reactor: reactor)
        bindTableViewHeader(reactor: reactor)
        bindSection(reactor: reactor)
        bindIsLoading(reactor: reactor)
        bindSelectedAppInfo(reactor: reactor)
        bindResultValue(reactor: reactor)
        bindSelectedRecentKeyword(reactor: reactor)
    }
}

// MARK: Action
extension SearchViewController {
    private func setFetchRecentKeyword(reactor: SearchViewReactor) {
        self.rx.viewWillAppear
            .take(1)
            .map { _ in Reactor.Action.fetchRecentKeywords }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindSearchBarText(reactor: SearchViewReactor) {
        searchController.searchBar.rx.text
            .filter { $0 != nil }
            .filter { $0!.isEmpty == false }
            .map { Reactor.Action.searchKeywordChanged($0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindSearchBarSearchButton(reactor: SearchViewReactor) {
        searchController.searchBar.rx.searchButtonClicked
            .map { [weak self] _ in
                guard let text = self?.searchController.searchBar.text else {
                    return Reactor.Action.searchKeyboardClicked("")
                }
                return Reactor.Action.searchKeyboardClicked(text)
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindSearchBarCancelButton(reactor: SearchViewReactor) {
        searchController.searchBar.rx.cancelButtonClicked
            .map { Reactor.Action.cancelButtonClicked }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindTableViewItem(reactor: SearchViewReactor) {
        tableview.rx.itemSelected
            .do(onNext: { [weak self] item in
                self?.tableview.deselectRow(at: IndexPath(row: item.row, section: 0), animated: false)
            })
            .map { Reactor.Action.selectCell($0.row) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

// MARK: State
extension SearchViewController {
    private func bindTableViewHeader(reactor: SearchViewReactor) {
        self.datasoure.titleForHeaderInSection = { datasource, index in
            return datasource.sectionModels[index].header
        }
    }
    
    private func bindSection(reactor: SearchViewReactor) {
        reactor.state
            .map { $0.section }
            .distinctUntilChanged()
            .bind(to: tableview.rx.items(dataSource: self.datasoure))
            .disposed(by: disposeBag)
    }
    
    private func bindSelectedAppInfo(reactor: SearchViewReactor) {
        reactor.pulse(\.$selectedAppInfo)
            .compactMap{ $0 }
            .subscribe { [weak self] entity in
                DispatchQueue.main.async {
                    self?.emptyView.isHidden = true
                    let detailViewController = AppRounter.detail(appInfo: entity).viewController
                    self?.navigationController?.pushViewController(detailViewController, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindResultValue(reactor: SearchViewReactor) {
        reactor.state
            .map{ $0.resultValue }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isResultCountZero, keyword in
                self?.noResultKeywordLabel.text = "'\(keyword)'"
                self?.emptyView.isHidden = !isResultCountZero
            }.disposed(by: disposeBag)
    }
    
    private func bindIsLoading(reactor: SearchViewReactor) {
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isLoading in
                self?.loadingView.isHidden = !isLoading
                isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
            }.disposed(by: disposeBag)
    }
    
    private func bindSelectedRecentKeyword(reactor: SearchViewReactor) {
        reactor.state
            .map { $0.selectedRecentKeyword }
            .filter { $0.isEmpty == false }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] selectedKeyword in
                self?.searchController.searchBar.becomeFirstResponder()
                self?.searchController.searchBar.text = selectedKeyword
                self?.reactor?.action.onNext(.searchKeyboardClicked(selectedKeyword))
                self?.searchController.searchBar.resignFirstResponder()
            }.disposed(by: disposeBag)
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
    private func createDataSource() -> RxTableViewSectionedAnimatedDataSource<SearchSection> {
        return .init(
            animationConfiguration: AnimationConfiguration(reloadAnimation: .none),
            configureCell: { _, tableview, indexPath, sectionItem in
                switch sectionItem {
                case let .searchItem(entity):
                    let cell = tableview.dequeue(Reusable.appInfoCell, for: indexPath)
                    cell.configure(entity)
                    return cell
                case let .recentKeyword(keyword):
                    let cell = tableview.dequeue(Reusable.keywordCell, for: indexPath)
                    // TODO: custon Cell로 변경
                    cell.textLabel?.text = keyword
                    return cell
                }
            }
        )
    }
}
