//
//  ChattingListTVCell.swift
//  GoodChatting
//
//  Created by 차윤오 on 1/15/24.
//

import UIKit
import SnapKit
import ReactorKit
import RxCocoa

class ChattingListTVCell: UITableViewCell {
    
    var mainImageView: UIImageView!
    var titleLabel: UILabel!
    var lastestMessageLabel: UILabel!
    var numberOfPeopleLabel: UILabel!
    var dateLabel: UILabel!
    var unReadLabel: UILabel!
    
    var cellButton: UIButton!
    
    var tapCellButton: ControlEvent<Void> {
        return cellButton.rx.tap
    }
    var disposeBag: DisposeBag = DisposeBag()
    
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
        
        disposeBag = DisposeBag()
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
        
        cellButton = UIButton().then {
            self.contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func configuration(item: ChattingList) {
        mainImageView.image = UIImage(named: item.image ?? "")
//        dateLabel.text = "\(item.updated_at ?? Date())"
        dateLabel.text = getDateStr(updated_at: item.updated_at ?? Date())
        titleLabel.text = item.title ?? ""
        lastestMessageLabel.text = item.newmessageCYO?.last?.message ?? ""
        numberOfPeopleLabel.text = "\(item.people?.count ?? 1)"
        
//        if let unRead = item.unRead, unRead > 0 {
//            unReadLabel.text = "\(unRead)"
//            unReadLabel.isHidden = false
//        }
    }
    
    func getDateStr(updated_at: Date) -> String {
        let date = Calendar.current.dateComponents([.day], from: updated_at, to: Date())
        let day = date.day ?? 0
        
        if day == 0 {
//            Log.cyo("오늘꺼")
            return GlobalFunctions.getDateStr(date: updated_at, format: "a hh:mm")
        } else if day == 1 {
//            Log.cyo("어제꺼")
            return "어제"
        } else {
            let todayYear = Calendar.current.dateComponents([.year], from: Date()).year ?? 0
            let updateYear = Calendar.current.dateComponents([.year], from: updated_at).year ?? 0
            
            if todayYear == updateYear {
//                Log.cyo("올해꺼")
                return GlobalFunctions.getDateStr(date: updated_at, format: "MM월 dd일")
            } else {
//                Log.cyo("올해아닌거 \(updated_at)")
                return GlobalFunctions.getDateStr(date: updated_at, format: "yyyy. MM. dd.")
            }
        }
    }
}
