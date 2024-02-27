//
//  ChatTableCell.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 1/23/24.
//

import UIKit

final class ChatMyCell: UITableViewCell {

    private var sendDate: UILabel!
    private var sendMessage: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(messageModel model: ChatMessageModel) {
        
        sendMessage.text = model.message
        sendDate.text = model.convertTimestamp
        
//        switch isCompare {
//        case true:
//            sendDate.text = ""
//            sendDate.isHidden = true
//        case false:
//            sendDate.text = model.convertTimestamp
//            sendDate.isHidden = false
//        }
    }
}

extension ChatMyCell {
    
    private func setConfigure() {
        
        self.selectionStyle = .none
        
        sendDate = UILabel().then {
            self.addSubview($0)
            $0.font = UIFont.appleSDGothicNeo(.medium, size: 9)
            $0.textColor = UIColor(
                red: 136/255, green: 136/255, blue: 136/255, alpha: 1.0
            )
            $0.snp.makeConstraints { make in
                make.left.greaterThanOrEqualToSuperview().offset(10)
                make.bottom.equalTo(self)
                make.height.equalTo(10)
            }
        }
        
        let messageBaseView = UIStackView(arrangedSubviews: []).then {
            self.addSubview($0)
            $0.backgroundColor = UIColor(
                red: 91/255, green: 214/255, blue: 255/255, alpha: 1.0
            )
            $0.layer.cornerRadius = 12
            $0.layer.maskedCorners = [
                .layerMaxXMinYCorner, .layerMinXMinYCorner,
                .layerMinXMaxYCorner
            ]
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = UIEdgeInsets(
                top: 0, left: 10, bottom: 0, right: 10
            )
            $0.snp.makeConstraints { make in
                make.left.equalTo(sendDate.snp.right).offset(6)
                make.right.equalTo(self).offset(-10)
                make.top.equalTo(self).offset(10)
                make.bottom.equalTo(self).offset(-10)
            }
        }
        
        sendMessage = UILabel().then {
            messageBaseView.addArrangedSubview($0)
            $0.font = UIFont.appleSDGothicNeo(.medium, size: 13)
        }
    }
}
