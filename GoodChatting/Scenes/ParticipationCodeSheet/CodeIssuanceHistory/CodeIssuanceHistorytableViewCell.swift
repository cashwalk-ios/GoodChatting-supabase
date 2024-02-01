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
    
    private var countLabel: UILabel!
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
    
    func configureCell(count: Int, code: String) {
        self.countLabel.text = "\(String(count))."
        self.codeLabel.text = code
    }
    
}

// MARK: - Layout

extension CodeIssuanceHistoryTableViewCell {
    
    private func setView() {
        
        let codeIconImageView = UIImageView().then {
            $0.image = UIImage(named: "codeIcon_expired")
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.size.equalTo(35)
                $0.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(10)
            }
        }
        
        self.countLabel = UILabel().then {
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(codeIconImageView.snp.right).offset(10)
            }
        }
        
        self.codeLabel = UILabel().then {
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.left.equalTo(self.countLabel.snp.right).offset(5)
            }
        }
        
        
    }
    
}
