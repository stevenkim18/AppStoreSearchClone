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
    
    let tableview = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let rightbarImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle")
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var items: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        self.navigationItem.title = "검색"
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "게임, 앱, 스토리 등 "
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        subviews()
        setConstraints()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? UITableViewCell else { return UITableViewCell() }
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "최근 검색어"
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        items.append(text)
        tableview.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        items.append(text)
        tableview.reloadData()
    }
}
