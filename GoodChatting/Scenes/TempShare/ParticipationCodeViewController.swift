//
//  ParticipationCodeViewController.swift
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

final class ParticipationCodeViewController: BaseViewController, View {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .designColor(color: .white())
        self.setView()
        
        guard let reactor = self.reactor else { return }
        bind(reactor: reactor)
    }
    
    deinit {
        Log.rk("ParticipationCodeViewController is Deinit!!")
    }
    
    // MARK: - Helpers
    
    func bind(reactor: ParticipationCodeReactor) {
        guard self.isViewLoaded else { return }
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
}

// MARK: - Bind

extension ParticipationCodeViewController {
 
    private func bindAction(reactor: ParticipationCodeReactor) {
        
        
    }
    
    private func bindState(reactor: ParticipationCodeReactor) {
        
    }
    
}

// MARK: - Layout

extension ParticipationCodeViewController {
    
    private func setView() {
        
        let participationImage = UIImageView().then {
            $0.image = UIImage(named: "participation_Icon")
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.size.equalTo(85)
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(39)
            }
        }
        
        
    }
    
}
