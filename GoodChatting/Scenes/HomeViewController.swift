//
//  HomeViewController.swift
//  GoodChatting
//
//  Created by Rocky on 1/4/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private var helloLabel: UILabel!
    private var tempRemoveUserDefaultsButton: UIButton!

    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupView()
    }
    
    // MARK: - Functions
    
    private func setupProperties() {
        self.view.backgroundColor = .designColor(color: .secondGray())
    }

    private func setupView() {
        helloLabel = UILabel().then {
            $0.text = "Hello, World!"
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        
        tempRemoveUserDefaultsButton = UIButton().then {
            $0.titleLabel?.text = "로그아웃"
            $0.tintColor = UIColor.white
            $0.backgroundColor = UIColor.red
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
                make.left.right.equalToSuperview().inset(20)
            }
        }
    }
    
    private func bindView() {
        tempRemoveUserDefaultsButton.rx.tap
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            }).disposed(by: disposeBag)
    }

}
