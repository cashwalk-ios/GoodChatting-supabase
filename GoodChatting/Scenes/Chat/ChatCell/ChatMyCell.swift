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
    
    func configure(message text: String) {
        
        sendMessage.text = text
        sendDate.text = "오후 1:12"
    }
}

extension ChatMyCell {
    
    private func setConfigure() {
        
        sendDate = UILabel().then {
            self.addSubview($0)
            $0.font = UIFont.systemFont(ofSize: 9)
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
                make.top.bottom.equalTo(self)
            }
        }
        
        sendMessage = UILabel().then {
            messageBaseView.addArrangedSubview($0)
            $0.font = UIFont.systemFont(ofSize: 15)
        }
    }
}
