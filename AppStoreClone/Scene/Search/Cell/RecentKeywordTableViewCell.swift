//
//  RecentKeywordTableViewCell.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2024/01/04.
//

import UIKit
import Then
import SnapKit

class RecentKeywordTableViewCell: UITableViewCell {
    
    let iconImageView = UIImageView().then {
        $0.image = UIImage(systemName: "magnifyingglass")
        $0.tintColor = .lightGray
    }
    
    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .black
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ keyword: String) {
        titleLabel.text = keyword
    }
    
    private func configureUI() {
        [iconImageView, titleLabel]
            .forEach { [weak self] view in
                self?.contentView.addSubview(view)
            }
    }
    
    private func setConstraints() {
        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(iconImageView.snp.right).offset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
}
