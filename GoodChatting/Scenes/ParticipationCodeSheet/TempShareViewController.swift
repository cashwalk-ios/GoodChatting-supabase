//
//  TenpShareViewController.swift
//  GoodChatting
//
//  Created by Rocky on 1/30/24.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class TempShareViewController: BaseViewController, View {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    private var inviteButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .designColor(color: .white())
        self.setView()
        self.reactor = TempShareReactor()
    }
    
    // MARK: - Helpers
    
    func bind(reactor: TempShareReactor) {
        guard self.isViewLoaded else { return }
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    // 완료 버튼 액션
    @objc private func doneAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Bind

extension TempShareViewController {
 
    private func bindAction(reactor: TempShareReactor) {

        self.inviteButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                Log.rk("Tap")
                let vc = ParticipationCodeViewController()
                vc.reactor = ParticipationCodeReactor()
                
                let nav = UINavigationController(rootViewController: vc)

                if let sheet = nav.sheetPresentationController {
                    sheet.detents = [
                        .custom(resolver: { context in
                            let height: CGFloat = 434
                            return height
                        })
                    ]
                    sheet.preferredCornerRadius = 15
                }
                
                let doneButton = UIBarButtonItem(title: "완료", style: .done, 
                                                 target: self, 
                                                 action: #selector(owner.doneAction))
                doneButton.tintColor = UIColor.init(hexCode: "5BD6FF")
                vc.navigationItem.rightBarButtonItem = doneButton
                
                owner.present(nav, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: TempShareReactor) {
        
    }
    
}

// MARK: - Layout

extension TempShareViewController {
    
    private func setView() {
        
        self.inviteButton = UIButton().then {
            $0.setTitle("초대하기", for: .normal)
            $0.setTitleColor(.designColor(color: .white()), for: .normal)
            $0.titleLabel?.font = .appleSDGothicNeo(.regular, size: 25)
            $0.layer.cornerRadius = 12
            $0.backgroundColor = .designColor(color: .black())
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.width.equalTo(200)
                $0.height.equalTo(100)
                $0.center.equalToSuperview()
            }
        }
        
    }
    
}
