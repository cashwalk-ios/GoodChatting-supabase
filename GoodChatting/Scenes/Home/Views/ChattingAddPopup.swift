//
//  ChattingAddPopup.swift
//  GoodChatting
//
//  Created by 차윤오 on 1/15/24.
//

import Foundation
import UIKit
import ReactorKit

class ChattingAddPopup: UIView {
    enum ChattingAddPopupAction {
        case makeRoom
        case joinRoom
    }
    
    var actionSubject = PublishSubject<ChattingAddPopupAction>.init()
    
    private let statusHeight: CGFloat
    
    private var containerView: UIView!
    
    private var makeRoomButton: UIButton!
    private var joinRoomButton: UIButton!
    private var closeButton: UIButton!
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    init(statusHeight: CGFloat) {
        self.statusHeight = statusHeight
        
        super.init(frame: .zero)
        
        setupProperties()
        setupView()
        bindView()
    }
    
    deinit {
        Log.cyo("ChattingAddPopup deinit")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupProperties() {
        self.backgroundColor = .init(white: 0, alpha: 0.8)
    }
    
    private func setupView() {
        containerView = UIView().then {
            $0.backgroundColor = .white
            self.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
//                make.height.equalTo(123 + statusHeight)
                make.height.equalTo(42 + statusHeight)
            }
        }
        
        let itemStack = UIStackView().then {
            $0.axis = .horizontal
            $0.spacing = 0
            $0.distribution = .fillEqually
            containerView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.bottom.right.equalToSuperview()
                make.height.equalTo(81)
            }
        }
        
        let _ = makeItem(type: .makeRoom).then {
            itemStack.addArrangedSubview($0)
        }
        
        let _ = makeItem(type: .joinRoom).then {
            itemStack.addArrangedSubview($0)
        }
        
        let labelContainer = UIView().then {
            $0.backgroundColor = .white
            containerView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(42 + statusHeight)
            }
        }
        
        let _ = UILabel().then {
            $0.text = "새로운 채팅"
            $0.font = UIFont.appleSDGothicNeo(.semiBold, size: 20)
            labelContainer.addSubview($0)
            
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(10 + statusHeight)
            }
        }
        
        closeButton = UIButton().then {
            $0.setImage(UIImage(named: "close-icon"), for: .normal)
            labelContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(5 + statusHeight)
                make.right.equalToSuperview().inset(9)
                make.size.equalTo(32)
            }
        }
    }
    
    private func bindView() {
        closeButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                Log.cyo("닫기")
                owner.removeFromSuperview()
            }.disposed(by: disposeBag)
        
        makeRoomButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                Log.cyo("만들기 룸")
                owner.actionSubject.onNext(.makeRoom)
                owner.removeFromSuperview()
            }.disposed(by: disposeBag)
        
        joinRoomButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                Log.cyo("참여하기 룸")
                owner.actionSubject.onNext(.joinRoom)
                owner.removeFromSuperview()
            }.disposed(by: disposeBag)
    }
    
    private func makeItem(type: ChattingAddPopupAction) -> UIView {
        let container = UIView().then {
            $0.backgroundColor = .clear
        }
        
        var imageStr: String = ""
        var titleStr: String = ""
        
        switch type {
        case .makeRoom:
            imageStr = "makeRoom-icon"
            titleStr = "채팅방 만들기"
            
        case .joinRoom:
            imageStr = "joinRoom-icon"
            titleStr = "참여하기"
        }
        
        let _ = UIImageView().then {
            $0.image = UIImage(named: imageStr)
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(13)
                make.size.equalTo(32)
            }
        }
        
        let _ = UILabel().then {
            $0.text = titleStr
            $0.font = UIFont.appleSDGothicNeo(.regular, size: 12)
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(13)
            }
        }
        
        switch type {
        case .makeRoom:
            makeRoomButton = UIButton().then {
                container.addSubview($0)
                $0.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        case .joinRoom:
            joinRoomButton = UIButton().then {
                container.addSubview($0)
                $0.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
        
        return container
    }
    
    func showAnimation() {
        Task {
            try await Task.sleep(nanoseconds: 100_000_000)
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self else { return }
                self.containerView.snp.updateConstraints { make in
                    make.height.equalTo(123 + self.statusHeight)
                }
                
                self.layoutIfNeeded()
            }
        }
    }
}
