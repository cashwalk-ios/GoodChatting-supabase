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
    private var tempRemoveLogoutButton: UIButton!

    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupView()
        bindView()
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
        
        tempRemoveLogoutButton = UIButton().then {
            $0.setTitle("로그아웃", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 24)
            $0.titleLabel?.textColor = .white
            $0.backgroundColor = UIColor.red
            $0.layer.cornerRadius = 15
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(50)
            }
        }
    }
    
    private func bindView() {
        tempRemoveLogoutButton.rx.tap
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                print("isLoggedIn UserDefaults 삭제...")
                UserDefaults.standard.removeObject(forKey: "isLoggedIn")
                exit(0)
            }).disposed(by: disposeBag)
    }

}
