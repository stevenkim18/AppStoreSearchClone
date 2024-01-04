//
//  ScreenShotCollectionViewCell.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/09.
//

import UIKit
import Then
import SnapKit
import Kingfisher

class ScreenShotCollectionViewCell: UICollectionViewCell {
    let screenImageView = UIImageView().then {
        $0.layer.cornerRadius = 22
        $0.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setContraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        self.contentView.addSubview(screenImageView)
    }
    
    private func setContraints() {
        screenImageView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
    }
    
    func configure(imageUrl: String) {
        screenImageView.kf.setImage(with: URL(string: imageUrl)!)
    }
}
