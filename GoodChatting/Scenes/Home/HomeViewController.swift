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
import ReactorKit

final class HomeViewController: BaseViewController, View {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    private var helloLabel: UILabel!
    private var tempLogoutButton: UIButton!

    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupView()
        
        guard let reactor = self.reactor else { return }
        bind(reactor: reactor)
    }
    
    // MARK: - Functions
    
    func bind(reactor: HomeReactor) {
        guard self.isViewLoaded else { return }
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    private func setupProperties() {
        self.view.backgroundColor = .designColor(color: .secondGray())
//        self.title = "Good Chatting"
        self.navigationItem.title = "Good Chatting"
    }

    private func setupView() {
        helloLabel = UILabel().then {
            $0.text = "Hello, World!"
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        
        tempLogoutButton = UIButton().then {
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

}

// MARK: - Bind

extension HomeViewController {
    
    private func bindAction(reactor: HomeReactor) {
        
        tempLogoutButton.rx.tap
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                let alert = GlobalFunctions.makeAlert(
                    title: "알림",
                    message: "정말 로그아웃하시겠습니까?",
                    firstActionMsg: "예",
                    firstActionHandler: {
                        UserSettings.isLoggedIn = false
                        // FIXME: SplashViewController로 연결할 것
                        owner.showToast(message: "앱을 재시작해주세요.")
                    },
                    cancelActionMsg: "취소"
                )
                owner.present(alert, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: HomeReactor) {
        
    }
    
}
