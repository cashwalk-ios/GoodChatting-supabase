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
    
}

// MARK: - Layout

extension CodeIssuanceHistoryTableViewCell {
    
    private func setView() {
        
    }
    
}
