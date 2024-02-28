//
//  SideMenuCell.swift
//  GoodChatting
//
//  Created by Rocky on 2/22/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class SideMenuCell: UITableViewCell {
    
    static public let cellIdentifier = "SideMenuCell"
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    var thumnailImageView: UIImageView!
    var roomManagerImageView: UIImageView!
    var meImageView: UIImageView!
    var nameLabel: UILabel!
    var editNameButton: UIButton!
    
    var tapEditNameButton: ControlEvent<Void> {
        return editNameButton.rx.tap
    }
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag() // 셀이 재사용될 준비될 때, disposeBag을 새로 할당하여 이전에 구독했던 이벤트들이 셀이 재사용될 때 취소되도록
    }
    
    // MARK: - Helpers

}

// MARK: - Layout

extension SideMenuCell {
    
    private func setView() {
        
        let thumnailImageContainer = UIView().then {
            self.contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().inset(10)
                $0.size.equalTo(32)
            }
        }
        
        self.thumnailImageView = UIImageView().then {
            $0.image = UIImage(named: "chatRoomProfileImage")
            $0.backgroundColor = .lightGray
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
            thumnailImageContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
                $0.size.equalTo(32)
            }
        }
        
        self.roomManagerImageView = UIImageView().then {
            $0.image = UIImage(named: "crown_Icon")
            $0.isHidden = true
            thumnailImageContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().offset(-2)
                $0.right.equalToSuperview().offset(4)
            }
        }
        
        self.meImageView = UIImageView().then {
            $0.image = UIImage(named: "me_Icon")
            $0.isHidden = true
            thumnailImageContainer.addSubview($0)
            $0.snp.makeConstraints {
                $0.bottom.equalToSuperview().offset(2)
                $0.right.equalToSuperview().offset(4)
            }
        }
        
        self.nameLabel = UILabel().then {
            $0.text = "이름"
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = .black
            self.contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(thumnailImageContainer.snp.right).offset(9)
            }
        }
        
        self.editNameButton = UIButton().then {
            $0.setImage(UIImage(named: "edit_Icon"), for: .normal)
            self.contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.size.equalTo(20)
                $0.right.equalToSuperview().inset(10)
                $0.centerY.equalToSuperview()
            }
        }
        
    }
}
