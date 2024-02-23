//
//  SideMenuViewController.swift
//  GoodChatting
//
//  Created by Rocky on 2/21/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import ReactorKit
import RxGesture

final class SideMenuViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    
    // MARK: - Properties
    
    private var dimmingView: UIView!
    var roomId: Int?

    private var inviteButton: UIButton!
    private var createDateLabel: UILabel!
    private var participantsCountLabel: UILabel!
    private var getoutButton: UIButton!
    private var notiButton: UIButton!
    
    private var participantsTableView: UITableView!
    
    var tempList: BehaviorSubject<[String]> = .init(value: ["name1", "name2", "name3", "name4", "name5"])

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 10
        self.view.clipsToBounds = true
        
        self.view.backgroundColor = .designColor(color: .white())
        self.setView()
        
        guard let reactor = self.reactor else { return }
        self.bind(reactor: reactor)
        
        if let roomId = self.roomId {
            reactor.action.onNext(.fetchChattingInfo(roomId: roomId))
        } else {
            GlobalFunctions.showToast(message: "roomId 가져오기 실패")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ParticipationCodeVCDismissAction), 
                                               name: .didDismissParticipationCodeVC, object: nil)
    }
    
    deinit {
        Log.rk("SideMenuVC Deinit!!")
    }
    
    // MARK: - Helpers
    
    func bind(reactor: SideMenuReactor) {
        guard self.isViewLoaded else { return }
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    @objc private func doneAction() {
        self.dimmingView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func ParticipationCodeVCDismissAction() {
        
        if dimmingView.isHidden == false {
            self.dimmingView.isHidden = true
        }
    }
    
}

// MARK: - bind

extension SideMenuViewController {
    
    private func bindAction(reactor: SideMenuReactor) {

        self.inviteButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
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
                                                 target: owner,
                                                 action: #selector(owner.doneAction))
                doneButton.tintColor = UIColor.init(hexCode: "5BD6FF")
                vc.navigationItem.rightBarButtonItem = doneButton
                
                owner.dimmingView.isHidden = false
                
                owner.present(nav, animated: true)
            }).disposed(by: disposeBag)
        
    }
    
    private func bindState(reactor: SideMenuReactor) {
        
        reactor.state.map{ $0.chattingInfo.first }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe { owner, roomInfo in
                Log.rk(roomInfo)
                owner.createDateLabel.text = "\(roomInfo.created_at)"
                owner.participantsCountLabel.text = "\(roomInfo.people?.count ?? 0)명"
            }.disposed(by: disposeBag)
        
        tempList.asObserver()
            .bind(to: participantsTableView.rx.items(cellIdentifier: SideMenuCell.cellIdentifier, cellType: SideMenuCell.self)) { row , item , cell in
                cell.configuration(name: item)
            }.disposed(by: disposeBag)
        
    }
    
}

// MARK: - Layout

extension SideMenuViewController {
    
    private func setView() {
        
        let topContainer = UIView().then {
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.left.right.equalToSuperview()
                $0.height.equalTo(63)
            }
        }
        
        let createTitle = UILabel().then {
            $0.text = "방 개설일"
            $0.font = .appleSDGothicNeo(.medium, size: 11)
            $0.textColor = .init(hexCode: "999999")
            $0.numberOfLines = 1
            topContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().inset(18)
                $0.left.equalToSuperview().inset(10)
                $0.height.equalTo(15)
            }
        }
        
        self.createDateLabel = UILabel().then {
            $0.text = "2024.02.22"
            $0.font = .appleSDGothicNeo(.medium, size: 11)
            $0.textColor = .init(hexCode: "999999")
            topContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(createTitle.snp.bottom).offset(2)
                $0.left.equalTo(createTitle.snp.left)
                $0.height.equalTo(15)
            }
        }
        
        let lineTop = UIView().then {
            $0.backgroundColor = .init(hexCode: "F6F7FA")
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(topContainer.snp.bottom)
                $0.left.right.equalToSuperview().inset(10)
                $0.height.equalTo(1)
            }
        }
        
        let middleContainer = UIView().then {
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(lineTop.snp.bottom)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(55)
            }
        }
        
        let participantsTitle = UILabel().then {
            $0.text = "참여자"
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = .init(hexCode: "999999")
            middleContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.left.equalToSuperview().inset(10)
                $0.bottom.equalToSuperview().inset(12)
                $0.height.equalTo(15)
            }
        }
        
        let participantsLine = UIView().then {
            $0.backgroundColor = .init(hexCode: "999999")
            middleContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalTo(participantsTitle.snp.centerY)
                $0.left.equalTo(participantsTitle.snp.right).offset(3)
                $0.width.equalTo(1)
                $0.height.equalTo(8)
            }
        }
        
        self.participantsCountLabel = UILabel().then {
            $0.text = "34명"
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = .init(hexCode: "999999")
            middleContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalTo(participantsTitle.snp.centerY)
                $0.left.equalTo(participantsLine.snp.right).offset(3)
                $0.height.equalTo(15)
            }
        }
        
        self.inviteButton = UIButton().then {
            $0.setImage(UIImage(named: "invite-icon"), for: .normal)
            $0.setTitle(" 초대하기", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .appleSDGothicNeo(.regular, size: 10)
            $0.backgroundColor = .init(white: 0, alpha: 0.7)
            $0.layer.cornerRadius = 3
            $0.clipsToBounds = true
            middleContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.right.equalToSuperview().inset(10)
                $0.bottom.equalToSuperview().inset(8)
                $0.width.equalTo(72)
                $0.height.equalTo(25)
            }
        }
        
        let bottomContainer = UIView().then {
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.left.right.equalToSuperview()
                $0.bottom.equalToSuperview().inset(78)
                $0.height.equalTo(48)
            }
        }
        
        self.getoutButton = UIButton().then {
            $0.setImage(UIImage(named: "getout-icon"), for: .normal)
            $0.tintColor = .clear
            bottomContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().inset(17)
                $0.size.equalTo(24)
            }
        }
        
        self.notiButton = UIButton().then {
            $0.setImage(UIImage(named: "bell-icon"), for: .normal)
            $0.tintColor = .clear
            bottomContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().inset(15)
                $0.size.equalTo(24)
            }
        }
        
        let lineBottom = UIView().then {
            $0.backgroundColor = .init(hexCode: "F6F7FA")
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(bottomContainer.snp.top)
                $0.left.right.equalToSuperview().inset(10)
                $0.height.equalTo(1)
            }
        }
        
        self.participantsTableView = UITableView().then {
            $0.rowHeight = 50
            $0.separatorColor = .clear
            $0.allowsSelection = false
            $0.register(SideMenuCell.self, forCellReuseIdentifier: SideMenuCell.cellIdentifier)
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(middleContainer.snp.bottom)
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(lineBottom.snp.top)
            }
        }
        
        self.dimmingView = UIView().then {
            $0.backgroundColor = .designColor(color: .black(0.5))
            $0.alpha = 0.5
            $0.isHidden = true
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
    }
    
}


