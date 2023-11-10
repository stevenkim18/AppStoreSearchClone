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

class AppListTableViewCell: UITableViewCell {
    
    let iconImageView = UIImageView(frame: .zero).then {
        $0.image = UIImage(systemName: "pencil")?.withBackground(color: .gray)
        $0.layer.cornerRadius = 14
        $0.layer.masksToBounds = true
    }
    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textColor = .black
        $0.text = "보라 성경"
    }
    let subtitleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor.init(red: 138/256, green: 138/256, blue: 141/256, alpha: 1)
        $0.text = "라이프 스타일"
    }
    let rateView = UIView()
    let rateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor.init(red: 196/256, green: 196/256, blue: 198/256, alpha: 1)
        $0.text = "5"
    }
    
    let downloadButton = UIButton().then {
        var title = AttributedString("받기")
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
        $0.image = UIImage.imageWithColor(tintColor: .red)
        $0.layer.cornerRadius = 11
        $0.layer.masksToBounds = true
    }
    let secondScreenShotImageView = UIImageView().then {
        $0.image = UIImage.imageWithColor(tintColor: .yellow)
        $0.layer.cornerRadius = 11
        $0.layer.masksToBounds = true
    }
    let thirdScreenShotImageView = UIImageView().then {
        $0.image = UIImage.imageWithColor(tintColor: .green)
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
            $0.top.equalToSuperview().offset(22)
            $0.left.equalToSuperview().offset(22)
            $0.width.equalTo(62)
            $0.height.equalTo(62)
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
            $0.top.equalTo(iconImageView.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
}

//extension UIImage {
//  func withBackground(color: UIColor, opaque: Bool = true) -> UIImage {
//    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
//        
//    guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
//    defer { UIGraphicsEndImageContext() }
//        
//    let rect = CGRect(origin: .zero, size: size)
//    ctx.setFillColor(color.cgColor)
//    ctx.fill(rect)
//    ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
//    ctx.draw(image, in: rect)
//        
//    return UIGraphicsGetImageFromCurrentImageContext() ?? self
//  }
//}
//
//extension UIImage {
//   static func imageWithColor(tintColor: UIColor) -> UIImage {
//        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
//        tintColor.setFill()
//        UIRectFill(rect)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return image
//    }
//}
//
//extension UIImageView {
//    func load(url: URL) {
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self?.image = image
//                    }
//                }
//            }
//        }
//    }
//}
