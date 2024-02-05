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
import Supabase

final class HomeViewController: BaseViewController, View {
    
    enum SettingAction: String {
        case edit = "채팅방 편집"
        case sort = "채팅방 정렬"
        case all_read = "모두 읽기"
    }
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    private var helloLabel: UILabel!
    private var tempLogoutButton: UIButton!
    private var chattingAddButton: UIButton!
    
    private var chattingListTableView: UITableView!
    private var blackView: BlackView!
    
    private var nothingListView: UIView!
    
    var settingAction = PublishSubject<SettingAction>()
    
    var createRoomPopup: CreateRoomView?
    var joinRoomPopup: JoinRoomView?
    
    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupNavivationItems()
        setupView()
        
        guard let reactor = self.reactor else { return }
        bind(reactor: reactor)
        
        ChattingListManager.shared.subcribeChannel()
        Task {
            do {
                try await ChattingListManager.shared.getChattingList()
            } catch {
                Log.cyo("get Room Error \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Functions
    
    func bind(reactor: HomeReactor) {
        guard self.isViewLoaded else { return }
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    private func setupProperties() {
        self.view.backgroundColor = .designColor(color: .secondGray())
    }
    
    private func setupNavivationItems() {
        var leftItems: [UIBarButtonItem] = []
        
        let _ = UIImageView().then {
            $0.image = UIImage(named: "launch-icon")
            leftItems.append(UIBarButtonItem(customView: $0))
            $0.snp.makeConstraints { make in
                make.size.equalTo(23)
            }
        }
        
        let _ = UIBarButtonItem(systemItem: .fixedSpace).then {
            $0.width = 15
            leftItems.append($0)
        }
        
        let _ = UILabel().then {
            $0.text = "Good Chatting"
            $0.font = UIFont.appleSDGothicNeo(.bold, size: 20)
            leftItems.append(UIBarButtonItem(customView: $0))
            $0.snp.makeConstraints { make in
                make.height.equalTo(22)
            }
        }
        
        self.navigationItem.leftBarButtonItems = leftItems
        
        var rightItems: [UIBarButtonItem] = []
        
        let settingItems: [UIAction] = [
            UIAction(title: SettingAction.edit.rawValue, handler: { [weak self] _ in self?.settingAction.onNext(.edit) }),
            UIAction(title: SettingAction.sort.rawValue, handler: { [weak self] _ in self?.settingAction.onNext(.sort) }),
            UIAction(title: SettingAction.all_read.rawValue, handler: { [weak self] _ in self?.settingAction.onNext(.all_read) })
        ]
        
        let _ = UIMenu(children: settingItems).then {
            rightItems.append(UIBarButtonItem(image: UIImage(named: "setting-icon")?.withRenderingMode(.alwaysOriginal), menu: $0))
        }
        
        let _ = UIBarButtonItem(systemItem: .fixedSpace).then {
            $0.width = 17
            rightItems.append($0)
        }
        
        chattingAddButton = UIButton().then {
            $0.setImage(UIImage(named: "chattingPlus-icon"), for: .normal)
            rightItems.append(UIBarButtonItem(customView: $0))
            $0.snp.makeConstraints { make in
                make.size.equalTo(23)
            }
        }
        
        self.navigationItem.rightBarButtonItems = rightItems
    }

    private func setupView() {
        chattingListTableView = UITableView().then {
            $0.estimatedRowHeight = 68
            $0.rowHeight = 68
            $0.separatorStyle = .none
            $0.allowsSelection = false
            $0.register(ChattingListTVCell.self, forCellReuseIdentifier: "listCell")
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        tempLogoutButton = UIButton().then {
            $0.setTitle("로그아웃", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16)
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
        
        nothingListView = UIView().then {
            $0.backgroundColor = .white
            $0.isHidden = false
            view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        let nothingContainer = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 38
            nothingListView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.horizontalEdges.equalToSuperview()
            }
        }
        
        let imageContainer = UIView().then {
            nothingContainer.addArrangedSubview($0)
            $0.snp.makeConstraints { make in
                make.height.equalTo(150)
            }
        }
        
        _ = UIImageView().then {
            $0.image = UIImage(named: "nothingMessage")
            $0.autoresizesSubviews = true
            imageContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(150)
            }
        }
        
        _ = UILabel().then {
            $0.text = "참여한 채팅방이 없어요."
            $0.numberOfLines = 0
            $0.font = .appleSDGothicNeo(.bold, size: 24)
            nothingContainer.addArrangedSubview($0)
            $0.snp.makeConstraints { make in
                make.height.equalTo(29)
            }
        }
    }

    fileprivate func presentLogoutAlert() {
        let blackView = BlackView(alphaValue: 0.7)
        blackView.show(onView: self.view)
        
        let alert = GlobalFunctions.makeAlert(
            title: "알림",
            message: "정말 로그아웃하시겠습니까?",
            firstActionMsg: "예",
            firstActionStyle: .destructive,
            firstActionHandler: {
                Task {
                    try await AuthManager.shared.signOut()
                    self.sceneDelegate?.navigateToSplash()
                }
                blackView.hide()
            },
            cancelActionMsg: "취소",
            cancelActionHandler: { blackView.hide() }
        )
        self.present(alert, animated: true)
    }
}

// MARK: - Bind

extension HomeViewController {
    
    private func bindAction(reactor: HomeReactor) {
        
        ChattingListManager.shared.subject
            .map({ Reactor.Action.chattingListManagerAction($0) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tempLogoutButton.rx.tap
            .throttle(.milliseconds(800), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                owner.presentLogoutAlert()
            }).disposed(by: disposeBag)
     
        chattingAddButton.rx.tap
            .subscribe(with: self) { owner, _ in
                let statusHeight = owner.sceneDelegate?.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
                Log.cyo("chatting plus 누름? \(statusHeight)")
                
                let addPopup = ChattingAddPopup(statusHeight: statusHeight)
                owner.sceneDelegate?.window?.addSubview(addPopup)
                
                addPopup.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                if let reactor = owner.reactor {
                    addPopup.actionSubject
                        .map { Reactor.Action.chattingAddAction($0) }
                        .bind(to: reactor.action)
                        .disposed(by: owner.disposeBag)
                }
                
                addPopup.showAnimation()
            }.disposed(by: disposeBag)
        
        settingAction
            .map { Reactor.Action.settingAction($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        chattingListTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: HomeReactor) {
        reactor.state.map(\.chattingList)
            .bind(to: chattingListTableView.rx.items(cellIdentifier: "listCell", cellType: ChattingListTVCell.self)) { row , item , cell in
                cell.configuration(item: item)
            }.disposed(by: disposeBag)
        
        reactor.state.map({ $0.chattingList.count > 0 })
            .bind(to: self.nothingListView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.isPresentCreateRoomPopup)
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, isPresent in
                owner.presentPopup(isPresent, owner, .create)
            }).disposed(by: disposeBag)
        
        reactor.state.map(\.isPresentJoinRoomPopup)
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, isPresent in
                owner.presentPopup(isPresent, owner, .join)
            }).disposed(by: disposeBag)
    }
    
    fileprivate func presentPopup(_ isPresent: Bool, _ owner: HomeViewController, _ popupType: ChatPopupType) {
        if isPresent {
            switch popupType {
            case .create:
                owner.createRoomPopup = CreateRoomView().then {
                    $0.reactor = owner.reactor
                    owner.sceneDelegate?.window?.addSubview($0)
                    $0.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                }
            case .join:
                owner.joinRoomPopup = JoinRoomView().then {
                    $0.reactor = owner.reactor
                    owner.sceneDelegate?.window?.addSubview($0)
                    $0.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                }
            }
        } else {
            switch popupType {
            case .create:
                owner.createRoomPopup?.removeFromSuperview()
            case .join:
                owner.joinRoomPopup?.removeFromSuperview()
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let getOutHandler: UIContextualAction.Handler = { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            Log.cyo("Get Out tapped")
            success(true)
        }
        let getOutAction = UIContextualAction(style: .normal, title: "나가기", handler: getOutHandler)
        
        getOutAction.image = UIImage(named: "getout")
        getOutAction.backgroundColor = UIColor.red
        
        
        let notiOffHandler: UIContextualAction.Handler = { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            Log.cyo("Noti Off tapped")
            success(true)
        }
        let notiOffAction = UIContextualAction(style: .normal, title: "알림 끄기", handler: notiOffHandler)
        
        notiOffAction.image = UIImage(named: "notioff")
        notiOffAction.backgroundColor = UIColor.init(hexCode: "5955D7")
        
        return UISwipeActionsConfiguration(actions: [getOutAction, notiOffAction])
    }
}
