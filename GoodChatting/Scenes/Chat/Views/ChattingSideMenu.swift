//
//  ChattingSideMenu.swift
//  GoodChatting
//
//  Created by 차윤오 on 2/1/24.
//

import Foundation
import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift

class ChattingSideMenu: UIView {
    enum SideMenuAction {
        case close
    }
    
    var containerView: UIView!
    
    var createDateLabel: UILabel!
    
    var participantsCountLabel: UILabel!
    var inviteButton: UIButton!
    var participantsTableView: UITableView!
    var getoutButton: UIButton!
    var notiButton: UIButton!
    
    private let statusHeight: CGFloat
    private let bottomHeight: CGFloat
    
    var actionSubject: PublishSubject<SideMenuAction> = .init()
    
    var tempList: BehaviorSubject<[String]> = .init(value: ["name1", "name2"])
    var disposeBag = DisposeBag()
    
    init(statusHeight: CGFloat, bottomHeight: CGFloat) {
        self.statusHeight = statusHeight
        self.bottomHeight = bottomHeight
        
        super.init(frame: .zero)
        
        setupProperties()
        setupView()
        bindView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupProperties() {
        self.backgroundColor = .init(white: 0, alpha: 0.5)
    }
    
    func setupView() {
        containerView = UIView().then {
            $0.backgroundColor = .white
            self.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(statusHeight)
                make.bottom.equalToSuperview()
                make.right.equalToSuperview().inset(-256)
                make.width.equalTo(256)
            }
        }
        
        let createContainer = UIView().then {
            containerView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(63)
            }
        }
        
        let createTitle = UILabel().then {
            $0.text = "방 개설일"
            $0.font = .appleSDGothicNeo(.medium, size: 11)
            $0.textColor = .init(hexCode: "999999")
            $0.numberOfLines = 1
            createContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(18)
                make.left.equalToSuperview().inset(7)
                make.height.equalTo(15)
            }
        }
        
        createDateLabel = UILabel().then {
            $0.text = "0000.00.00"
            $0.font = .appleSDGothicNeo(.medium, size: 11)
            $0.textColor = .init(hexCode: "999999")
            createContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(createTitle.snp.bottom).offset(2)
                make.left.equalToSuperview().inset(10)
                make.height.equalTo(15)
            }
        }
        
        let lineTop = UIView().then {
            $0.backgroundColor = .init(hexCode: "F6F7FA")
            containerView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(createContainer.snp.bottom)
                make.left.right.equalToSuperview().inset(10)
                make.height.equalTo(1)
            }
        }
        
        let bottomContainer = UIView().then {
            containerView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(bottomHeight)
                make.height.equalTo(48)
            }
        }
        
        getoutButton = UIButton().then {
            $0.setImage(UIImage(named: "getout-icon"), for: .normal)
            $0.tintColor = .clear
            bottomContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().inset(17)
                make.size.equalTo(24)
            }
        }
        
        notiButton = UIButton().then {
            $0.setImage(UIImage(named: "bell-icon"), for: .normal)
            $0.tintColor = .clear
            bottomContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().inset(15)
                make.size.equalTo(24)
            }
        }
        
        let lineBottom = UIView().then {
            $0.backgroundColor = .init(hexCode: "F6F7FA")
            containerView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(bottomContainer.snp.top)
                make.left.right.equalToSuperview().inset(10)
                make.height.equalTo(1)
            }
        }
        
        let middleContainer = UIView().then {
            containerView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(lineTop.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(55)
            }
        }
        
        let participantsTitle = UILabel().then {
            $0.text = "참여자"
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = .init(hexCode: "999999")
            middleContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(10)
                make.bottom.equalToSuperview().inset(12)
                make.height.equalTo(15)
            }
        }
        
        let participantsLine = UIView().then {
            $0.backgroundColor = .init(hexCode: "999999")
            middleContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerY.equalTo(participantsTitle.snp.centerY)
                make.left.equalTo(participantsTitle.snp.right).offset(3)
                make.width.equalTo(1)
                make.height.equalTo(8)
            }
        }
        
        participantsCountLabel = UILabel().then {
            $0.text = "1432명"
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = .init(hexCode: "999999")
            middleContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerY.equalTo(participantsTitle.snp.centerY)
                make.left.equalTo(participantsLine.snp.right).offset(3)
                make.height.equalTo(15)
            }
        }
        
        inviteButton = UIButton().then {
            $0.setImage(UIImage(named: "invite-icon"), for: .normal)
            $0.setTitle(" 초대하기", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .appleSDGothicNeo(.regular, size: 10)
            $0.backgroundColor = .init(white: 0, alpha: 0.7)
            $0.layer.cornerRadius = 3
            $0.clipsToBounds = true
            middleContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(10)
                make.bottom.equalToSuperview().inset(8)
                make.width.equalTo(72)
                make.height.equalTo(25)
            }
        }
        
        participantsTableView = UITableView().then {
            $0.rowHeight = 50
            $0.separatorColor = .clear
            $0.allowsSelection = false
            $0.register(ChattingSideMenuCell.self, forCellReuseIdentifier: "participantCell")
            containerView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(middleContainer.snp.bottom)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(lineBottom.snp.top)
            }
        }
    }
    
    func bindView() {
        tempList.asObserver()
            .bind(to: participantsTableView.rx.items(cellIdentifier: "participantCell", cellType: ChattingSideMenuCell.self)) { row , item , cell in
                cell.configuration(name: item)
            }.disposed(by: disposeBag)
    }
    
    func showAnimation() {
        Task {
            try await Task.sleep(nanoseconds: 100_000_000)
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                self.containerView.snp.updateConstraints { make in
                    make.right.equalToSuperview().inset(0)
                }
                
                self.layoutIfNeeded()
            }
        }
    }
}
