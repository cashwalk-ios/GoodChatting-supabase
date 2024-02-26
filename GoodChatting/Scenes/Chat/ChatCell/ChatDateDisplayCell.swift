//
//  ChatDateDisplayCell.swift
//  GoodChatting
//
//  Created by kimtaeuk-N275 on 2/1/24.
//

import UIKit
import SnapKit

final class ChatDateDisplayCell: UITableViewCell {
    
    let identifier: String = "ChatDate"
    private var displayLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setConfigure(displayText dateText: String) {
        
        displayLabel = UILabel().then {
            self.addSubview($0)
            $0.text = dateText
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.textColor = .gray
            $0.snp.makeConstraints { make in
                make.centerX.centerY.equalTo(self)
                make.height.equalTo(10)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        displayLabel.text = nil
    }
}
