//
//  SideMenuCell.swift
//  GoodChatting
//
//  Created by Rocky on 2/22/24.
//

import UIKit
import SnapKit
import Then

final class SideMenuCell: UITableViewCell {
    
    static public let cellIdentifier = "SideMenuCell"
    
    // MARK: - Properties
    
    var thumnailImageView: UIImageView!
    var crownImageView: UIImageView! // me or 방장 아이콘
    var nameLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
    }
    
    // MARK: - Helpers
    
    func configuration(name: String) {
        nameLabel.text = name
    }
}

// MARK: - Layout

extension SideMenuCell {
    
    private func setView() {
        
        self.thumnailImageView = UIImageView().then {
            $0.image = UIImage(named: "chatRoomProfileImage")
            $0.backgroundColor = .lightGray
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().inset(10)
                $0.size.equalTo(32)
            }
        }
        
        self.nameLabel = UILabel().then {
            $0.text = "이름"
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = .black
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(thumnailImageView.snp.right).offset(9)
            }
        }
        
    }
    
}
