//
//  DetailViewController.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/09.
//

import UIKit
import Then
import SnapKit

class DetailViewController: UIViewController {
    
    let scrollview = UIScrollView()
    
    let stackview = UIStackView().then {
        $0.axis = .vertical
    }
    
    // 앱 아이콘
    let iconImageView = UIImageView().then {
        $0.layer.cornerRadius = 24
        $0.layer.masksToBounds = true
    }
    // 앱 제목
    let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.numberOfLines = 2
    }
    // 회사 이름
    let developerLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor.init(red: 138/255, green: 138/255, blue: 138/255, alpha: 1)
    }
    // 다운로드 버튼
    let downloadButton = UIButton(configuration: .filled()).then {
        $0.setTitle("받기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 14
    }
    // 공유 버튼
    let shareButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(systemName: "square.and.arrow.up")
        
        $0.configuration = configuration
    }
    
    let topView = UIView()
    
    // 스크린 샷들
    let screenShotCollectionView = UICollectionView(frame: .zero,
                                                    collectionViewLayout: UICollectionViewFlowLayout().then({
        $0.scrollDirection = .horizontal
        $0.itemSize = CGSize(width: 270, height: 480)
    })).then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
        $0.isPagingEnabled = false
        $0.decelerationRate = .fast
    }
    
    let screenShotView = UIView()
    
    // 앱 설명
    let descriptionLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.numberOfLines = 3
    }
    
    // 더보기
    let descriptionMoreButton = UIButton(configuration: .plain()).then {
        $0.setTitle("더보기", for: .normal)
    }
    
    let bottomView = UIView()
    
    private let appinfo: AppInfoEntity
    
    init(appinfo: AppInfoEntity) {
        self.appinfo = appinfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        subviews()
        setContraints()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationItem.largeTitleDisplayMode = .always
    }
    
    private func subviews() {
        view.addSubview(scrollview)
        scrollview.addSubview(stackview)
        
        stackview.addArrangedSubview(topView)
        
        [iconImageView,
         titleLabel, developerLabel, downloadButton,
         shareButton].forEach {
            topView.addSubview($0)
        }
        
        stackview.addArrangedSubview(screenShotView)
        
        screenShotView.addSubview(screenShotCollectionView)
        
        stackview.addArrangedSubview(bottomView)
        
        [descriptionLabel, descriptionMoreButton].forEach {
            bottomView.addSubview($0)
        }

        screenShotCollectionView.register(ScreenShotCollectionViewCell.self,
                                          forCellWithReuseIdentifier: "ScreenShotCollectionViewCell")
        screenShotCollectionView.dataSource = self
        screenShotCollectionView.delegate = self
        
        descriptionMoreButton.addAction(UIAction(handler: { _ in
            // TODO: 실제 앱스토어 애니메이션 처럼
            UIView.animate(withDuration: 0.6, animations: {
                let lineCount = self.descriptionLabel.numberOfLines
                let flag = lineCount == 0
                self.descriptionLabel.numberOfLines = flag ? 3 : 0
            })
        }), for: .touchUpInside)
    }
    
    private func setContraints() {
        scrollview.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackview.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        topView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.left.equalToSuperview().offset(19)
            $0.width.height.equalTo(114)
            $0.bottom.equalToSuperview().offset(-20)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.top).inset(3)
            $0.left.equalTo(iconImageView.snp.right).offset(15)
            $0.right.equalTo(19)
        }

        developerLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(1)
            $0.left.equalTo(titleLabel.snp.left)
        }

        downloadButton.snp.makeConstraints {
            $0.width.equalTo(70)
            $0.height.equalTo(28)
            $0.left.equalTo(titleLabel.snp.left)
            $0.bottom.equalTo(iconImageView.snp.bottom)
        }

        shareButton.snp.makeConstraints {
            $0.width.height.equalTo(23)
            $0.right.equalTo(-19)
            $0.bottom.equalTo(downloadButton.snp.bottom)
        }
        
        screenShotView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }

        screenShotCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(480)
        }

        bottomView.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.left.equalTo(19)
            $0.right.equalTo(-19)
            $0.bottom.equalTo(-20)
        }
        
        descriptionMoreButton.snp.makeConstraints {
            $0.right.equalTo(-19)
            $0.bottom.equalTo(-20)
        }
    }
    
    private func configure() {
        iconImageView.load(url: URL.init(string: appinfo.artworkUrl512)! )
        titleLabel.text = appinfo.trackName
        developerLabel.text = appinfo.artistName
        descriptionLabel.text = appinfo.description
    }

}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        appinfo.screenshotUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenShotCollectionViewCell", for: indexPath) as? ScreenShotCollectionViewCell else {
            return UICollectionViewCell()
        }
        let imageUrl = appinfo.screenshotUrls[indexPath.row]
        cell.configure(imageUrl: imageUrl)
        return cell
    }
    
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = CGFloat(270 + 10)
        let index = round(scrolledOffsetX / cellWidth)
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
    }
}
