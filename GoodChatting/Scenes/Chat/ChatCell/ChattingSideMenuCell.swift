//
//  ChattingSideMenuCell.swift
//  GoodChatting
//
//  Created by 차윤오 on 2/2/24.
//

import Foundation
import UIKit
import SnapKit
import Then

class ChattingSideMenuCell: UITableViewCell {
    
    var thumnailImageView: UIImageView!
    var crownImageView: UIImageView!    // me or 방장 아이콘
    var nameLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
    }
    
    func setupView() {
        thumnailImageView = UIImageView().then {
            $0.image = UIImage(named: "template01")
            $0.backgroundColor = .lightGray
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().inset(10)
                make.size.equalTo(32)
            }
        }
        
        nameLabel = UILabel().then {
            $0.text = "이름"
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = .black
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(thumnailImageView.snp.right).offset(9)
            }
        }
    }
    
    func configuration(name: String) {
        nameLabel.text = name
    }
}
