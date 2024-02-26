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

class ChatViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()

    private var chatView: ChatView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConfigure()
        guard let reactor = self.reactor else { return }
        bind(reactor: reactor)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func bind(reactor: ChatReactor) {
        guard self.isViewLoaded else { return }
        
        reactor.action.onNext(.fetchChatData)
        reactor.action.onNext(.insertSubscribe)
        
        reactor.state.map(\.reload)
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { owner, state in
                if let state, state == true {
                    DispatchQueue.main.async {
                        owner.chatView.tableView.reloadData()
                        owner.scrollToBottom()
                    }
                }
            }).disposed(by: disposeBag)
        
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
                
//                let ss = reactor.currentState.chatList[index - 1]
                // 날짜 비교
//                ss.created_at
                
                switch reactor.currentState.userData.id == model.user_id {
                case true:
                    /// 나의 채팅
                    guard let cell = self.chatView.tableView.dequeueReusableCell(withIdentifier: "myChat") as? ChatMyCell else { return UITableViewCell() }
                    Log.cyo(model)
                    cell.configure(messageModel: model)
                    return cell
                case false:
                    /// 상대방 채팅
                    guard let cell = self.chatView.tableView.dequeueReusableCell(withIdentifier: "otherChat") as? ChatOtherCell else { return UITableViewCell() }
                    
                    cell.configure(messageModel: model)
                    return cell
                }
                
            }.disposed(by: disposeBag)
        
//        reactor.state.map(\.chatList)
//            .distinctUntilChanged()
//            .withUnretained(self)
//            .subscribe(onNext: { owner, list in
//                
//                if list.count != 0 {
//                    owner.scrollToBottom()
//                }
//            }).disposed(by: disposeBag)
            
        
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
        let statusHeight = self.sceneDelegate?.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let bottomHeight = self.sceneDelegate?.window?.safeAreaInsets.bottom ?? 0
        
        let sideMenu = ChattingSideMenu(statusHeight: statusHeight, bottomHeight: bottomHeight)
        self.sceneDelegate?.window?.addSubview(sideMenu)
        
        sideMenu.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if let reactor = self.reactor {
            sideMenu.actionSubject
                .map({ Reactor.Action.sideMenuAction(action: $0) })
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        sideMenu.showAnimation()
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
        return 53
    }
}

extension ChatViewController {
    
    private func setConfigure() {
        
        self.view.backgroundColor = .white
        
        chatView = ChatView().then {
            self.view.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
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
//        self.chatView.tableView.register(ChatDateDisplayCell.self, forCellReuseIdentifier: "123")
        self.chatView.tableView.register(ChatMyCell.self, forCellReuseIdentifier: "myChat")
        self.chatView.tableView.register(ChatOtherCell.self, forCellReuseIdentifier: "otherChat")
        self.chatView.tableView.delegate = self
        self.chatView.messageTextField.delegate = self
    }
}
