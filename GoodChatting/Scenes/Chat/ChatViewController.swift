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
    }
    
    func bind(reactor: ChatReactor) {
        
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
    }
    
    @objc
    private func selectHamburgerButton(_ sender: UIBarButtonItem) {
        
        
    }
    
    @objc
    private func backAction(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
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
    }
}
