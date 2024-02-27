//
//  ChatOtherCell.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 2/6/24.
//

import UIKit

class ChatOtherCell: UITableViewCell {

    private var personImageView: UIImageView!
    private var personName: UILabel!
    private var personMessage: UILabel!
    private var recievdDate: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(messageModel model: ChatMessageModel, otherModel someModel: [RoomUserCYO]) {
        
        someModel.forEach {
            if let roomUserId = $0.user_id, roomUserId == model.user_id {
                personName.text = $0.nickname ?? "알 수 없음"
                personMessage.text = model.message
                recievdDate.text = model.convertTimestamp
            }
        }
    }

}

extension ChatOtherCell {
    
    private func setConfigure() {
    
        self.selectionStyle = .none
        
        personImageView = UIImageView().then {
            self.addSubview($0)
            $0.layer.cornerRadius = 8
            $0.image = UIImage(named: "launch-icon")
            $0.snp.makeConstraints { make in
                make.height.width.equalTo(30)
                make.top.equalTo(self)
                make.left.equalTo(self).offset(10)
            }
        }
        
        personName = UILabel().then {
            self.addSubview($0)
            $0.font = UIFont.appleSDGothicNeo(.medium, size: 10)
            $0.snp.makeConstraints { make in
                make.top.equalTo(self).offset(4)
                make.left.equalTo(personImageView.snp.right).offset(7)
                make.height.equalTo(13)
            }
        }
        
        let chatBaseView = UIStackView(arrangedSubviews: []).then {
            self.addSubview($0)
            $0.backgroundColor = UIColor(
                red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0
            )
            $0.layer.cornerRadius = 12
            $0.layer.maskedCorners = [
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner, .layerMaxXMaxYCorner
            ]
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = UIEdgeInsets(
                top: 0, left: 10, bottom: 0, right: 10
            )
            $0.snp.makeConstraints { make in
                make.top.equalTo(personName.snp.bottom).offset(6)
                make.left.equalTo(personName)
                make.bottom.equalTo(self).offset(-5)
            }
        }
        
        personMessage = UILabel().then {
            chatBaseView.addArrangedSubview($0)
            $0.font = UIFont.appleSDGothicNeo(.medium, size: 13)
            $0.text = "[사용자가 방을 나갔습니다]"
        }
        
        recievdDate = UILabel().then {
            self.addSubview($0)
            $0.font = UIFont.systemFont(ofSize: 9)
            $0.textColor = UIColor(
                red: 136/255, green: 136/255, blue: 136/255, alpha: 1.0
            )
            $0.snp.makeConstraints { make in
                make.left.equalTo(chatBaseView.snp.right).offset(6)
                make.bottom.equalTo(chatBaseView.snp.bottom)
                make.height.equalTo(10)
                make.right.lessThanOrEqualTo(self).offset(-10)
            }
        }
    }
}
