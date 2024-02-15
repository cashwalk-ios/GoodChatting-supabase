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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setConfigure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(message text: String) {
        personName.text = "김아영"
        personMessage.text = text
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
                make.top.left.equalTo(self)
            }
        }
        
        personName = UILabel().then {
            self.addSubview($0)
            $0.font = UIFont.systemFont(ofSize: 11)
            $0.snp.makeConstraints { make in
                make.top.equalTo(self).offset(2)
                make.left.equalTo(personImageView.snp.right).offset(7)
                make.height.equalTo(13)
            }
        }
        
        let chatBaseView = UIStackView(arrangedSubviews: []).then {
            self.addSubview($0)
            $0.backgroundColor = UIColor.lightGray
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
                make.bottom.equalTo(self)
                make.right.lessThanOrEqualTo(self).offset(-10)
            }
        }
        
        personMessage = UILabel().then {
            chatBaseView.addArrangedSubview($0)
            $0.font = UIFont.systemFont(ofSize: 15)
        }
    }
}
