//
//  ChatViewController.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 1/23/24.
//

import UIKit
import ReactorKit

class ChatViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()

    private var chatView: ChatView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConfigure()
        guard let reactor = self.reactor else { return }
        bind(reactor: reactor)
    }
    
    func bind(reactor: ChatReactor) {
        guard self.isViewLoaded else { return }
        
        reactor.state.map(\.chattingRoomTitle)
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { owner, roomTitle in
                
                let roomPeople = reactor.currentState.roomPeopleCount
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
        
        reactor.state.map(\.testChatList)
            .bind(to: chatView.tableView.rx.items) { [weak self]
                cell, index, _ -> UITableViewCell in
                guard let self else { fatalError("self Error") }
                
//                guard let cell = self.chatView.tableView.dequeueReusableCell(withIdentifier: "123") as? ChatDateDisplayCell else { return UITableViewCell() }
//                
//                cell.setConfigure(displayText: "test")
                guard let cell = self.chatView.tableView.dequeueReusableCell(withIdentifier: "qwer") as? ChatMyCell else { return UITableViewCell() }
                
                cell.configure(message: "안녕하세요")
                return cell
            }.disposed(by: disposeBag)
    }
    
    @objc
    private func selectHamburgerButton(_ sender: UIBarButtonItem) {
        
    }
    
    @objc
    private func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
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
        self.chatView.tableView.register(ChatDateDisplayCell.self, forCellReuseIdentifier: "123")
        self.chatView.tableView.register(ChatMyCell.self, forCellReuseIdentifier: "qwer")
        self.chatView.tableView.delegate = self
    }
}
