//
//  ChatViewController.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 1/23/24.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import RxKeyboard

class ChatViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()

    private var sideMenuViewController = SideMenuViewController()
    private var dimmingView: UIView!
    private var statusHeight: CGFloat?
    
    private var chatView: ChatView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConfigure()
        guard let reactor = self.reactor else { return }
        bind(reactor: reactor)
        
        self.sideMenuViewController.reactor = SideMenuReactor()
        self.sideMenuViewController.sceneDelegate = self.sceneDelegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(backAction(_:)),
                                               name: .getOutRoom, object: nil)
    }
    
    deinit {
        Log.rk("ChatVC Deinit!!")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sideMenuViewController.view.removeFromSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func bind(reactor: ChatReactor) {
        guard self.isViewLoaded else { return }
        
        reactor.action.onNext(.fetchChatData)
        reactor.action.onNext(.insertSubscribe)
        
        reactor.state.map(\.chattingRoomTitle)
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { owner, roomTitle in
                
                let roomPeople = reactor.currentState.roomData.people?.count ?? 1
                let tempTitle = "\(roomTitle) \(roomPeople)"
                let titleAttributedString = NSMutableAttributedString(string: tempTitle)
                
                titleAttributedString.addAttribute(
                    .font,
                    value: UIFont.systemFont(ofSize: 15),
                    range: (tempTitle as NSString).range(of: "\(roomPeople)")
                )
                
                titleAttributedString.addAttribute(
                    .foregroundColor,
                    value: UIColor.lightGray,
                    range: (tempTitle as NSString).range(of: "\(roomPeople)")
                )
              
                let titleLabel = UILabel()
                titleLabel.attributedText = titleAttributedString
                owner.navigationItem.titleView = titleLabel
            }).disposed(by: disposeBag)
        
        reactor.state.map(\.chatList)
            .bind(to: chatView.tableView.rx.items) { [weak self] cell, index, model -> UITableViewCell in
                guard let self else { fatalError("self Error") }
                
                if index > 2 && index != reactor.currentState.chatList.count - 1 {
                    let previousCell = reactor.currentState.chatList[index - 2].created_at
                    let currenctCell = reactor.currentState.chatList[index - 1].created_at
                    
                    let isBool = model.isCompareCreateDate(
                        previousCellDate: previousCell,
                        currentCellDate: currenctCell
                    )
                    
                    switch isBool {
                    case true:
                        guard let cell = self.chatView.tableView.dequeueReusableCell(withIdentifier: "ChatDate") as? ChatDateDisplayCell else { return UITableViewCell() }
                        cell.setConfigure(displayText: model.displayDateCell)
                        return cell
                    case false: break
                    }
                }
                
                switch reactor.currentState.userData.id == model.user_id {
                case true:
                    /// 나의 채팅
                    guard let cell = self.chatView.tableView.dequeueReusableCell(withIdentifier: "myChat") as? ChatMyCell else { return UITableViewCell() }
                    
//                    var isCompare: Bool = true
//                    
//                    if index > 2 {
//                        let previousCell = reactor.currentState.chatList[index - 2].created_at
//                        let currenctCell = reactor.currentState.chatList[index - 1].created_at
//                        
//                        isCompare = model.isCompareChatDate(
//                            previousCellDate: previousCell,
//                            currentCellDate: currenctCell
//                        )
//                    }
                    
                    cell.configure(messageModel: model)
                    return cell
                case false:
                    /// 상대방 채팅
                    guard let cell = self.chatView.tableView.dequeueReusableCell(withIdentifier: "otherChat") as? ChatOtherCell else { return UITableViewCell() }
                    
                    cell.configure(messageModel: model, 
                                   otherModel: reactor.currentState.roomData.roomUserCYO ?? [])
                    return cell
                }
                
            }.disposed(by: disposeBag)
        
        reactor.state.map { $0.roomData.id }
            .withUnretained(self)
            .subscribe(onNext: { owner, roomId in
                Log.rk("RoomId is \(roomId)")
                owner.sideMenuViewController.roomId = roomId
            }).disposed(by: disposeBag)
        
        reactor.state.map(\.chatList)
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.scrollToBottom()
            }).disposed(by: disposeBag)
        
        chatView.messageTextField.rx.text
            .orEmpty
            .withUnretained(self)
            .subscribe(onNext: { owner, text in
                switch text {
                case "":
                    owner.chatView.sendButton.backgroundColor = .lightGray
                default:
                    owner.chatView.sendButton.backgroundColor = .blue
                }
            }).disposed(by: disposeBag)
        
        chatView.sendButton.rx
            .tap
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                if owner.chatView.messageTextField.text?.isEmpty == false,
                    let textMessage = owner.chatView.messageTextField.text {
                    
                    Log.cyo("touch Button")
                    reactor.action.onNext(.sendMessage(text: textMessage))
                    owner.chatView.messageTextField.text = ""
                }
            }).disposed(by: disposeBag)
        
        dimmingView.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                guard let window = owner.sceneDelegate?.window else { return }
                
                UIView.animate(withDuration: 0.3, animations: {
                    // 사이드 메뉴를 화면 오른쪽 바깥으로 이동
                    owner.sideMenuViewController.view.snp.updateConstraints {
                        $0.right.equalTo(window.snp.right).offset(window.frame.width * 0.65)
                    }
                    window.layoutIfNeeded()
                    owner.dimmingView.alpha = 0
                }) { finished in
                    // 애니메이션 완료 후 사이드 메뉴를 뷰 계층 구조에서 제거
                    window.removeFromSuperview()
                    owner.sideMenuViewController.removeFromParent()
                    
                    owner.dimmingView.isHidden = true
                }
            }).disposed(by: disposeBag)
        
    }
    
    @objc
    private func selectHamburgerButton(_ sender: UIBarButtonItem) {
        showSideMenu()
    }
    
    @objc
    private func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func showSideMenu() {
        guard let window = self.sceneDelegate?.window else { return }
        window.addSubview(self.sideMenuViewController.view)
        self.addChild(self.sideMenuViewController)
        
        // 사이드 메뉴의 뷰에 대한 초기 제약 조건 설정
        self.sideMenuViewController.view.snp.makeConstraints {
            $0.width.equalTo(window.frame.width * 0.65) // 화면 너비의 65%로 설정
            $0.height.equalTo(window)
            $0.top.equalToSuperview().inset(statusHeight ?? 0)
            $0.right.equalTo(window.snp.right).offset(window.frame.width * 0.65) // 초기에는 화면 오른쪽 바깥으로 설정
        }
        
        self.dimmingView.isHidden = false
        self.dimmingView.alpha = 0
        
        window.layoutIfNeeded()
        self.dimmingView.alpha = 0.5

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                // 사이드 메뉴 노출시키도록 오른쪽 제약 조건 업데이트
                self.sideMenuViewController.view.snp.updateConstraints {
                    $0.right.equalTo(window.snp.right) // 화면 오른쪽 끝으로 이동
                }
                
                window.layoutIfNeeded()
            })
        }
        
    }
    
    private func scrollToBottom() {
        
        let lastIndex = chatView.tableView.numberOfSections - 1
        let lastRow = chatView.tableView.numberOfRows(inSection: lastIndex) - 1
        
        if lastIndex >= 0 && lastRow >= 0 {
            let indexPath = IndexPath(row: lastRow, section: lastIndex)
            chatView.tableView.scrollToRow(
                at: indexPath,
                at: .bottom,
                animated: true
            )
        }
    }
    
    private func setKeyboard() {
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self else { return }
                
                var dynamicKeyboardHeight: CGFloat = 0
                
                if keyboardVisibleHeight > 0 {
                    dynamicKeyboardHeight = -keyboardVisibleHeight + self.chatView.safeAreaInsets.bottom
                    
                    DispatchQueue.main.async {
                        self.scrollToBottom()
                    }
                } else {
                    dynamicKeyboardHeight = 0
                }
                
                self.chatView.messageTextField.snp.updateConstraints {
                    $0.bottom.equalTo(self.chatView.safeAreaLayoutGuide)
                        .offset(dynamicKeyboardHeight)
                }
                
                self.chatView.layoutIfNeeded()
            }).disposed(by: disposeBag)
    }
}

extension ChatViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        chatView.messageTextField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatView.messageTextField.resignFirstResponder()
        return true
    }
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}

extension ChatViewController {
    
    private func setConfigure() {
        
        self.view.backgroundColor = .designColor(color: .white())
        
        statusHeight = self.sceneDelegate?.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        chatView = ChatView().then {
            self.view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
                make.left.right.equalToSuperview()
            }
        }
        
        let leftBackButton = UIBarButtonItem(
            image: UIImage(named: "backImage"),
            style: .plain,
            target: self,
            action: #selector(backAction(_:)))
        leftBackButton.tintColor = .black
        navigationItem.leftBarButtonItem = leftBackButton
        
        let rightBarButton = UIBarButtonItem(
            image: UIImage(named: "menu-hamburger"),
            style: .plain,
            target: self,
            action: #selector(selectHamburgerButton(_:))
        )
        rightBarButton.tintColor = .black
        
        navigationItem.rightBarButtonItem = rightBarButton
        self.chatView.tableView.register(ChatDateDisplayCell.self, forCellReuseIdentifier: "ChatDate")
        self.chatView.tableView.register(ChatMyCell.self, forCellReuseIdentifier: "myChat")
        self.chatView.tableView.register(ChatOtherCell.self, forCellReuseIdentifier: "otherChat")
        self.chatView.tableView.delegate = self
        self.chatView.messageTextField.delegate = self
        
        self.dimmingView = UIView().then {
            $0.backgroundColor = .designColor(color: .black(0.5))
            $0.isHidden = true
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        // setting
        self.setKeyboard()
    }
}
