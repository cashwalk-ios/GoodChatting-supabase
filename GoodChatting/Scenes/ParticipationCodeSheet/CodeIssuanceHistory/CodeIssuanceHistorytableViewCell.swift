//
//  CodeIssuanceHistorytableViewCell.swift
//  GoodChatting
//
//  Created by Rocky on 2/1/24.
//

import UIKit
import Then
import SnapKit

final class CodeIssuanceHistoryTableViewCell: UITableViewCell {
    
    static public let cellIdentifier = "CodeIssuanceHistoryTableViewCell"
    
    // MARK: - Properties
    
    private var iconImageView: UIImageView!
    private var tempCountLabel: UILabel!
    private var deleteAllLabel: UILabel!
    private var codeLabel: UILabel!
    private var labelStack: UIStackView!
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureDeleteCell() {
        self.deleteAllLabel.isHidden = false
        self.labelStack.isHidden = true
        self.tempCountLabel.isHidden = true
     
        self.iconImageView.image = UIImage(named: "trash_Icon")
        self.iconImageView.snp.updateConstraints {
            $0.size.equalTo(24)
            $0.left.equalToSuperview().offset(19)
        }
    }
    
    func configureCell(count: Int, code: String) {
        self.tempCountLabel.text = String(count)
        self.codeLabel.text = code
    }
    
}

// MARK: - Layout

extension CodeIssuanceHistoryTableViewCell {
    
    private func setView() {
        
        self.iconImageView = UIImageView().then {
            $0.image = UIImage(named: "codeIcon_expired")
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.size.equalTo(35)
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(10)
            }
        }
        
        self.deleteAllLabel = UILabel().then {
            $0.text = "만료된 코드 모두 삭제"
            $0.font = .appleSDGothicNeo(.regular, size: 16)
            $0.textColor = UIColor.init(hexCode: "FF3A30")
            $0.isHidden = true
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(self.iconImageView.snp.right).offset(10)
            }
        }
        
        self.codeLabel = UILabel().then {
            $0.font = .appleSDGothicNeo(.regular, size: 16)
        }
        
        let codeInfoLabel = UILabel().then {
            $0.text = "참가자 4명 ∙ 만료됨"
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = UIColor.init(hexCode: "6D6D71")
        }
        
        self.labelStack = UIStackView(arrangedSubviews: [self.codeLabel, codeInfoLabel]).then {
            $0.axis = .vertical
            $0.spacing = 2
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(self.iconImageView.snp.right).offset(10)
            }
        }
        
        self.tempCountLabel = UILabel().then {
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.right.equalToSuperview().offset(-10)
            }
        }
        
    }
    
}
