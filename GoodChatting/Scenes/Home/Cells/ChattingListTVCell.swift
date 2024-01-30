//
//  ChattingListTVCell.swift
//  GoodChatting
//
//  Created by 차윤오 on 1/15/24.
//

import UIKit
import SnapKit

class ChattingListTVCell: UITableViewCell {
    
    var mainImageView: UIImageView!
    var titleLabel: UILabel!
    var lastestMessageLabel: UILabel!
    var numberOfPeopleLabel: UILabel!
    var dateLabel: UILabel!
    var unReadLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        mainImageView.image = nil
        titleLabel.text = ""
        lastestMessageLabel.text = ""
        numberOfPeopleLabel.text = ""
        dateLabel.text = ""
        unReadLabel.text = ""
        unReadLabel.isHidden = true
    }
    
    func setupView() {
        mainImageView = UIImageView().then {
            $0.image = UIImage(named: "template01")
            $0.backgroundColor = .lightGray
            $0.layer.cornerRadius = 10
            $0.clipsToBounds = true
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().inset(15)
                make.size.equalTo(45)
            }
        }
        
        let rightContainer = UIView().then {
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
            }
        }
        
        dateLabel = UILabel().then {
            $0.font = .appleSDGothicNeo(.regular, size: 10)
            $0.textColor = UIColor(white: 153/255, alpha: 1.0)
            $0.numberOfLines = 1
            $0.textAlignment = .right
            rightContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalToSuperview().offset(11)
                make.right.equalToSuperview().inset(14)
            }
        }
        
        unReadLabel = UILabel().then {
            $0.font = .appleSDGothicNeo(.regular, size: 11)
            $0.textColor = .white
            $0.numberOfLines = 1
            $0.textAlignment = .center
            $0.backgroundColor = UIColor(hexCode: "58D6FF")
            $0.layer.cornerRadius = 9
            $0.clipsToBounds = true
            $0.isHidden = true
            rightContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.size.equalTo(18)
                make.right.equalToSuperview().inset(14)
                make.bottom.equalToSuperview().inset(18)
            }
        }
        
        let middleContainer = UIView().then {
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.left.equalTo(mainImageView.snp.right).offset(10)
                make.right.equalTo(rightContainer.snp.left).offset(-10)
            }
        }
        
        titleLabel = UILabel().then {
            $0.font = .appleSDGothicNeo(.medium, size: 13)
            $0.textColor = .black
            $0.numberOfLines = 1
            $0.textAlignment = .left
            middleContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalToSuperview().offset(13)
                make.height.equalTo(22)
            }
        }
        
        lastestMessageLabel = UILabel().then {
            $0.font = .appleSDGothicNeo(.regular, size: 11)
            $0.textColor = UIColor(white: 153/255, alpha: 1.0)
            $0.numberOfLines = 1
            middleContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.bottom.equalToSuperview().inset(14)
                make.height.equalTo(22)
            }
        }
        
        numberOfPeopleLabel = UILabel().then {
            $0.font = .appleSDGothicNeo(.regular, size: 11)
            $0.textColor = UIColor(white: 153/255, alpha: 1.0)
            $0.numberOfLines = 1
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            middleContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.equalTo(titleLabel.snp.right).offset(4)
                make.right.equalToSuperview()
                make.centerY.equalTo(titleLabel.snp.centerY)
            }
        }
    }
    
    func configuration(item: ChattingList) {
        mainImageView.image = UIImage(named: item.image ?? "")
        dateLabel.text = "\(item.updated_at ?? Date())"
        titleLabel.text = item.title ?? ""
        lastestMessageLabel.text = item.messageCYO?.last?.message ?? ""
        numberOfPeopleLabel.text = "\(item.people?.count ?? 1)"
        
//        if let unRead = item.unRead, unRead > 0 {
//            unReadLabel.text = "\(unRead)"
//            unReadLabel.isHidden = false
//        }
    }
}
