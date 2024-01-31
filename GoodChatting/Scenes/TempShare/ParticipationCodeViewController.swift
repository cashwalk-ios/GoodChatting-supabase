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
    
    private var moreButton: UIButton!
    private var participationCode: UILabel!
    private var shareButton: UIButton!
    
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
        
        let title = UILabel().then {
            $0.text = "참여 코드"
            $0.font = .appleSDGothicNeo(.semiBold, size: 21)
            $0.textColor = UIColor.designColor(color: .black())
        }
        
        let subtitle = UILabel().then {
            $0.text = "참여 코드를 공유하여 다른 사람을 초대할 수 있어요."
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = UIColor.init(hexCode: "6D6D71")
        }
        
        let titleStackView = UIStackView(arrangedSubviews: [title, subtitle]).then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 9
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(participationImage.snp.bottom).offset(23)
                $0.centerX.equalToSuperview()
            }
        }
        
        let codeBoxView = UIView().then {
            $0.layer.cornerRadius = 8
            $0.backgroundColor = UIColor.init(hexCode: "F2F2F7")
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = true
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.height.equalTo(47)
                $0.top.equalTo(titleStackView.snp.bottom).offset(31)
                $0.left.right.equalToSuperview().inset(15)
            }
        }
        
        self.moreButton = UIButton().then {
            $0.setImage(UIImage(named: "more_Icon"), for: .normal)
            codeBoxView.addSubview($0)
            $0.snp.makeConstraints {
                $0.size.equalTo(22)
                $0.right.equalToSuperview().offset(-12.4)
                $0.centerY.equalToSuperview()
            }
        }

        self.participationCode = UILabel().then {
            $0.text = "g.sh/+3bNCRMGeF_3mOFU2"
            $0.font = .appleSDGothicNeo(.medium, size: 17)
            $0.textColor = UIColor.designColor(color: .black())
            codeBoxView.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview()
            }
        }
        
        let description = UILabel().then {
            $0.text = "* 참여 코드를 새로 발급할 경우 이전의 참여 코드는 사용할 수 없습니다."
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = UIColor.init(hexCode: "B2B2B2")
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(codeBoxView.snp.bottom).offset(10)
                $0.centerX.equalToSuperview()
            }
        }
        
        self.shareButton = UIButton().then {
            $0.setTitle("공유하기", for: .normal)
            $0.setTitleColor(.designColor(color: .white()), for: .normal)
            $0.titleLabel?.font = .appleSDGothicNeo(.bold, size: 16)
            $0.layer.cornerRadius = 8
            $0.backgroundColor = UIColor.init(hexCode: "5BD6FF")
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.height.equalTo(48)
                $0.top.equalTo(description.snp.bottom).offset(39)
                $0.left.right.equalToSuperview().inset(15)
            }
        }
        
    }
    
}
