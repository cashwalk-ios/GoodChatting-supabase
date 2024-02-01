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
    private var deleteLabel: UILabel!
    private var codeLabel: UILabel!
    
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
    
    func setIconImageSize(size: Int, leftOffset: Int) {
        self.iconImageView.snp.updateConstraints {
            $0.size.equalTo(size)
            $0.left.equalToSuperview().offset(leftOffset)
        }
    }
    
    func showDeleteLabel() {
        self.deleteLabel.isHidden = false
        self.tempCountLabel.isHidden = true
    }
    
    func configureCell(iconImage: UIImage, count: Int, code: String) {
        self.iconImageView.image = iconImage
        self.tempCountLabel.text = "\(String(count))."
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
        
        self.tempCountLabel = UILabel().then {
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(self.iconImageView.snp.right).offset(10)
            }
        }
        
        self.deleteLabel = UILabel().then {
            $0.text = "만료된 코드 모두 삭제"
            $0.font = .appleSDGothicNeo(.regular, size: 15)
            $0.textColor = UIColor.init(hexCode: "FF3A30")
            $0.isHidden = true
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(self.iconImageView.snp.right).offset(10)
            }
        }
        
        self.codeLabel = UILabel().then {
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(self.tempCountLabel.snp.right).offset(5)
            }
        }
        
        
    }
    
}
