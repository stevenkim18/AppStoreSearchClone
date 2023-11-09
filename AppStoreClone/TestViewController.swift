//
//  TestViewController.swift
//  AppStoreClone
//
//  Created by seungwooKim on 2023/11/10.
//

import UIKit
import Then
import SnapKit

class TestViewController: UIViewController {
    
    let scrollview = UIScrollView().then {
        $0.backgroundColor = .orange
    }
    
    let stackView = UIStackView().then {
        $0.backgroundColor = .yellow
        $0.axis = .vertical
    }
    
    let view1 = UIView().then {
        $0.backgroundColor = .green
    }
    
    let view2 = UIView().then {
        $0.backgroundColor = .purple
    }
    
    let view3 = UIView().then {
        $0.backgroundColor = .blue
    }
    
    let button = UIButton(configuration: .filled()).then {
        $0.setTitle("버튼", for: .normal)
    }
    
    let label = UILabel().then {
        $0.text = """
These are short, famous texts in English from classic sources like the Bible or Shakespeare. Some texts have word definitions and explanations to help you. Some of these texts are written in an old style of English. Try to understand them, because the English that we speak today is based on what our great, great, great, great grandparents spoke before! Of course, not all these texts were originally written in English. The Bible, for example, is a translation. But they are all well known in English today, and many of them express beautiful thoughts.
"""
//        $0.numberOfLines = 0
    }
    
    private var flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        
        
        view.addSubview(scrollview)
        
        scrollview.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollview.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        stackView.addArrangedSubview(view3)
        
        view1.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
        view2.snp.makeConstraints { make in
            make.height.equalTo(300)
        }
        view3.snp.makeConstraints { make in
            
        }
        
        view3.addSubview(button)
        view3.addSubview(label)
        
        button.snp.makeConstraints { make in
            make.top.left.equalTo(50)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(button.snp.bottom).offset(40)
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.bottom.equalTo(-50)
        }
        
        button.addAction(UIAction(handler: { _ in
            self.flag.toggle()
            self.label.numberOfLines = self.flag ? 0 : 1
        }), for: .touchUpInside)
    }

}
