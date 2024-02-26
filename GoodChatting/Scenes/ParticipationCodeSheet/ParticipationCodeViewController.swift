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
    
    private var codeBoxView: UIView!
    private var moreButton: UIButton!
    private var participationCode: UILabel!
    private var shareButton: UIButton!
    
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .designColor(color: .white())
        self.setView()
        
        guard let reactor = self.reactor else { return }
        bind(reactor: reactor)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.post(name: .didDismissParticipationCodeVC, object: nil)
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
    
    private func setupGenerator() {
        self.feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        self.feedbackGenerator?.prepare()
    }
    
}

// MARK: - Bind

extension ParticipationCodeViewController {
 
    private func bindAction(reactor: ParticipationCodeReactor) {
        
        self.codeBoxView.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.setupGenerator()
                owner.feedbackGenerator?.impactOccurred()

                UIPasteboard.general.string = GlobalFunctions.makeShareLink(joinCode: owner.participationCode.text ?? "")
                owner.showToast(message: "참여 코드가 복사되었어요.", duration: 1.5)

            }).disposed(by: disposeBag)
        
        self.codeBoxView.rx.longPressGesture(configuration: { gestureRecognizer, _ in
            gestureRecognizer.minimumPressDuration = 0.01 })
        .withUnretained(self)
        .subscribe(onNext: { owner, gesture in
            switch gesture.state {
            case .began:
                // 손가락이 뷰에 닿았을 때
                UIView.animate(withDuration: 0.1) {
                    owner.codeBoxView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
                    owner.codeBoxView.layer.shadowRadius = 2
                }
            case .ended, .cancelled:
                // 손가락이 뷰에서 떨어졌을 때
                UIView.animate(withDuration: 0.1) {
                    owner.codeBoxView.transform = CGAffineTransform.identity
                    owner.codeBoxView.layer.shadowRadius = 4
                }
            default: break
            }
        }).disposed(by: disposeBag)
        
        self.shareButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                guard let participationCode = owner.participationCode.text else { return }
                var participationCodeToShare = GlobalFunctions.makeShareLink(joinCode: participationCode)
                
                var stringToShare = [String]()
                stringToShare.append(
                """
                굿채팅의 세계로 초대합니다.
                
                참여 코드: \(participationCodeToShare)
                """)
                
                let activityVC = UIActivityViewController(activityItems : stringToShare, applicationActivities: nil)
                
                // 공유하기 기능 중 제외할 기능
                activityVC.excludedActivityTypes = [
                    UIActivity.ActivityType.print,
                    UIActivity.ActivityType.postToWeibo,
                    UIActivity.ActivityType.postToTencentWeibo,
                    UIActivity.ActivityType.postToTwitter,
                    UIActivity.ActivityType.postToFacebook,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.addToReadingList
                ]
                activityVC.popoverPresentationController?.sourceView = owner.view
                owner.present(activityVC, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: ParticipationCodeReactor) {
     
        reactor.state.map { $0.activeParticipationCode }
            .withUnretained(self)
            .subscribe(onNext: { owner, code in
                owner.participationCode.text = code
            }).disposed(by: disposeBag)
        
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
        
        self.codeBoxView = UIView().then {
            $0.layer.cornerRadius = 8
            $0.backgroundColor = UIColor.init(hexCode: "F2F2F7")
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = true
            $0.layer.shadowColor = UIColor.designColor(color: .black()).cgColor
            $0.layer.shadowOffset = CGSize(width: 0, height: 4)
            $0.layer.shadowRadius = 4
            $0.layer.shadowOpacity = 0.25
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.height.equalTo(47)
                $0.top.equalTo(titleStackView.snp.bottom).offset(31)
                $0.left.right.equalToSuperview().inset(15)
            }
        }
        
        self.moreButton = UIButton().then {
            $0.setImage(UIImage(named: "more_Icon"), for: .normal)
            
            let menuItems: [UIMenuElement] = [
                UIAction(title: "복사", image: UIImage(named: "copy_Icon"), handler: { [weak self] _ in
                    guard let self = self, let codeText = self.participationCode.text else { return }
                    UIPasteboard.general.string = GlobalFunctions.makeShareLink(joinCode: codeText)
                    self.showToast(message: "참여 코드가 복사되었어요.", duration: 1.5)
                }),
                UIAction(title: "코드 발급 기록", image: UIImage(named: "document_Icon"), handler: { [weak self] _ in
                    guard let self else { return }
                    let vc = CodeIssuanceHistoryViewController()
                    vc.reactor = CodeIssuanceHistoryReactor()
                    
                    let nav = UINavigationController(rootViewController: vc)
                    self.present(nav, animated: true)
                }),
                UIAction(title: "새로 발급", image: UIImage(named: "rotate_Icon"), attributes: .destructive, handler: { [weak self] _ in
                    guard let self else { return }
                    // TODO: - Supabase에서 키 새로 발급하는 로직
                    // Temp
                    let tempRandomCode = [
                        "g.sh/+3bNCRMGeF_3mOFU2",
                        "g.sh/+6hBCXSGeF_4bOFU2",
                        "g.sh/+8yKRWOEtIU_3dWRF9",
                        "g.sh/+5rGXQCYtQZ_1dUGS2",
                        "g.sh/+7nHUYVGeKJ_2fXRT3",
                        "g.sh/+9mIVXDFtLQ_4gZSA4",
                        "g.sh/+1oJWZEGuMP_5hTBV5",
                        "g.sh/+2pKXYFHvNQ_6iUCW6",
                        "g.sh/+4qLZYGIwOR_7jVDX7"
                    ].randomElement()
                    self.participationCode.text = tempRandomCode
                    self.showToast(message: "참여 코드가 새로 발급되었습니다.", duration: 2.0)
                })
            ]
            
            $0.menu = UIMenu(title: "", children: menuItems)
            $0.showsMenuAsPrimaryAction = true
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
