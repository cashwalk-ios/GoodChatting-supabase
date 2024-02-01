//
//  ChatView.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 1/30/24.
//

import UIKit

final class ChatView: UIView {

    var tableView: UITableView!
    var messageTextField: UITextField!
    var sendButton: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChatView {
    
    private func setConfigure() {
        
        self.backgroundColor = .clear
        
        messageTextField = UITextField().then {
            self.addSubview($0)
            $0.backgroundColor = UIColor(
                red: 246/255,
                green: 246/255,
                blue: 246/255,
                alpha: 0.93
            )
            $0.leftView = UIView(frame: CGRect(
                x: 0, y: 0, width: 20, height: 40)
            )
            $0.leftViewMode = .always
            $0.placeholder = "메시지 보내기"
            $0.layer.cornerRadius = 20
            $0.snp.makeConstraints { make in
                make.left.equalTo(self).offset(20)
                make.right.equalTo(self).offset(-20)
                make.bottom.equalTo(self.safeAreaLayoutGuide)
                make.height.equalTo(40)
            }
        }
        
        sendButton = UIView().then {
            messageTextField.addSubview($0)
            $0.layer.cornerRadius = 15
            $0.backgroundColor = .gray
            $0.snp.makeConstraints { make in
                make.height.width.equalTo(30)
                make.right.equalTo(messageTextField.snp.right).offset(-10)
                make.centerY.equalTo(messageTextField.snp.centerY)
            }
        }
        
        let sendButtonImage = UIImageView().then {
            sendButton.addSubview($0)
            $0.image = UIImage(named: "chatSendImage")
            $0.snp.makeConstraints { make in
                make.centerX.centerY.equalTo(sendButton)
                make.width.height.equalTo(15)
            }
        }
        
        tableView = UITableView().then {
            self.addSubview($0)
            $0.backgroundColor = .white
            $0.separatorStyle = .none
            $0.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(messageTextField.snp.top)
            }
        }
    }
}
