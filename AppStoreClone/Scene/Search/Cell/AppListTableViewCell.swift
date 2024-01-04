//
//  AppListTableViewCell.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/02.
//

import UIKit
import Then
import SnapKit
import Kingfisher

// TODO: Cell에도 리엑터 만들어 보기
class AppListTableViewCell: UITableViewCell {
    // MARK: Constants
    private enum Constants {
        static let downloadButtonText = "받기"
        static let iconSize = 62
        static let iconMargin = 22
        static let screenShotViewMargin = 20
        static let screenShotViewHeight = 228
    }
    
    let iconImageView = UIImageView(frame: .zero).then {
        $0.layer.cornerRadius = 14
        $0.layer.masksToBounds = true
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textColor = .black
    }
    let subtitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor(r: 138, g: 138, b: 141)
    }
    let rateView = UIView()
    let rateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor(r: 196, g: 196, b: 198)
    }
    
    let downloadButton = UIButton().then {
        var title = AttributedString(Constants.downloadButtonText)
        title.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        var configuration = UIButton.Configuration.gray()
        configuration.attributedTitle = title
        
        $0.configuration = configuration
        
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 13.5
    }
    
    let appImageStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 8
    }
    
    let firstScreenShotImageView = UIImageView().then {
        $0.layer.cornerRadius = 11
        $0.layer.masksToBounds = true
    }
    let secondScreenShotImageView = UIImageView().then {
        $0.layer.cornerRadius = 11
        $0.layer.masksToBounds = true
    }
    let thirdScreenShotImageView = UIImageView().then {
        $0.layer.cornerRadius = 11
        $0.layer.masksToBounds = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        subviews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ entity: AppInfoEntity) {
        // TODO: 킹피셔를 사용하지 않을 떄는 이미지가 깜빡 거림. 원인 알아야 함.
        iconImageView.kf.setImage(with: URL(string: entity.artworkUrl100)!)
        titleLabel.text = entity.trackName
        subtitleLabel.text = entity.genres.joined(separator: ", ")
        rateLabel.text = String(format: "%.1f", entity.averageUserRating)
        firstScreenShotImageView.kf.setImage(with: URL(string: entity.screenshotUrls[0])!)
        // TODO: URL 없는 경우 처리
        secondScreenShotImageView.kf.setImage(with: URL(string: entity.screenshotUrls[1])!)
        thirdScreenShotImageView.kf.setImage(with: URL(string: entity.screenshotUrls[2])!)
    }
    
    private func subviews() {
        [iconImageView,
         titleLabel, subtitleLabel, rateLabel,
         downloadButton, appImageStackView].forEach { [weak self] view in
            self?.contentView.addSubview(view)
        }
        [firstScreenShotImageView,
         secondScreenShotImageView,
         thirdScreenShotImageView].forEach { [weak self] imageview in
            self?.appImageStackView.addArrangedSubview(imageview)
        }
    }
    
    private func setConstraints() {
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.iconMargin)
            $0.left.equalToSuperview().offset(Constants.iconMargin)
            $0.width.equalTo(Constants.iconSize)
            $0.height.equalTo(Constants.iconSize)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.top)
            $0.left.equalTo(iconImageView.snp.right).offset(10)
            $0.right.equalTo(downloadButton.snp.left).offset(-10)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(3)
            $0.left.equalTo(titleLabel.snp.left)
        }
        
        rateLabel.snp.makeConstraints {
            $0.left.equalTo(titleLabel.snp.left)
            $0.bottom.equalTo(iconImageView.snp.bottom)
        }
        
        downloadButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(38)
            $0.right.equalToSuperview().offset(-20)
            $0.width.equalTo(69)
            $0.height.equalTo(27)
        }
        
        appImageStackView.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(Constants.screenShotViewMargin)
            $0.left.equalToSuperview().offset(Constants.screenShotViewMargin)
            $0.right.equalToSuperview().offset(-Constants.screenShotViewMargin)
            $0.height.equalTo(Constants.screenShotViewHeight)
        }
    }
}

// MARK: Cell Height
extension AppListTableViewCell {
    class func height() -> CGFloat {
        return CGFloat(Constants.iconMargin +
                       Constants.iconSize +
                       Constants.screenShotViewMargin +
                       Constants.screenShotViewHeight +
                       Constants.screenShotViewMargin)
    }
}

