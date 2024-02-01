//
//  CreateRoomViewController.swift
//  GoodChatting
//
//  Created by 김광록 on 2/1/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxGesture

final class CreateRoomView: UIView {
    
    var disposeBag = DisposeBag()
    var closeButton: UIView!
    var createButton: UIView!
    var profileImage: UIImageView!
    var camIcon: UIImageView!
    var chatRoomTitle: UITextView!
    var titleSizeLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setupProperties()
        self.setupViews()
        self.bindView()
        self.addTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.kkr("\(self)")
    }
    
    private func setupProperties() {
        self.backgroundColor = .black.withAlphaComponent(0.8)
    }
    
    private func setupViews() {
        let container = UIView().then {
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.width.equalTo(321)
                make.height.equalTo(364)
                make.center.equalToSuperview()
            }
        }
        
        _ = UIView().then {
            $0.backgroundColor = .init(hexCode: "5BD6FF")
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(125)
            }
        }
        
        // 채팅방 프로필 이미지
        
        let profileCamImageContainer = UIView().then {
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.size.equalTo(100)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(60)
            }
        }
        
        profileImage = UIImageView().then {
            $0.image = UIImage(named: "chatRoomProfileImage")
            $0.isUserInteractionEnabled = true
            $0.layer.cornerRadius = 50
            $0.clipsToBounds = true
            profileCamImageContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.size.equalTo(100)
            }
        }
        
        camIcon = UIImageView().then {
            $0.image = UIImage(named: "camera_icon")
            profileCamImageContainer.addSubview($0)
            $0.snp.makeConstraints { make in
                make.size.equalTo(24)
                make.right.bottom.equalToSuperview().inset(2)
            }
        }
        
        // 하단 버튼
        
        createButton = UIView().then {
            $0.backgroundColor = .init(hexCode: "5BD6FF")
            $0.layer.cornerRadius = 8
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.right.bottom.equalToSuperview().inset(20)
                make.width.equalTo(130)
                make.height.equalTo(48)
            }
        }
        
        _ = UILabel().then {
            $0.text = "채팅방 만들기"
            $0.textColor = .white
            $0.font = .appleSDGothicNeo(.semiBold, size: 16)
            createButton.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        
        closeButton = UIView().then {
            $0.backgroundColor = .designColor(color: .mainGray(1))
            $0.layer.cornerRadius = 8
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.bottom.equalToSuperview().inset(20)
                make.width.equalTo(130)
                make.height.equalTo(48)
            }
        }
        
        _ = UILabel().then {
            $0.text = "닫기"
            $0.textColor = .black
            $0.font = .appleSDGothicNeo(.semiBold, size: 16)
            closeButton.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        
        // 채팅방 타이틀 레이블
        
        let underline = UIView().then {
            $0.backgroundColor = .init(hexCode: "E0E0E0")
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(1)
                make.bottom.equalTo(closeButton.snp.top).offset(-50)
            }
        }
        
        chatRoomTitle = UITextView().then {
            $0.font = .appleSDGothicNeo(.semiBold, size: 16)
            $0.isScrollEnabled = false
            $0.delegate = self
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.right.equalTo(underline).inset(3)
                make.bottom.equalTo(underline.snp.top).offset(-8)
                make.height.equalTo(30)
            }
        }

        titleSizeLabel = UILabel().then {
            $0.text = "0/30"
            $0.textColor = .init(hexCode: "B2B2B2")
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(20)
                make.bottom.equalTo(chatRoomTitle.snp.top).offset(-5)
            }
        }

        
//        chatRoomTitle = UITextField().then {
//            $0.placeholder = "채팅방 이름을 입력해주세요."
//            $0.delegate = self
//            $0.font = .appleSDGothicNeo(.semiBold, size: 16)
//        }
//        
//        titleSizeLabel = UILabel().then {
//            $0.text = "0/30"
//            $0.textColor = .init(hexCode: "B2B2B2")
//            $0.font = .appleSDGothicNeo(.regular, size: 12)
//        }
//        
//        _ = UIStackView(arrangedSubviews: [chatRoomTitle, titleSizeLabel]).then {
//            $0.distribution = .fill
//            addSubview($0)
//            $0.snp.makeConstraints { make in
//                make.left.right.equalTo(underline).inset(3)
//                make.bottom.equalTo(underline.snp.top).offset(-8)
//            }
//        }
        
    }
    
    private func bindView() {
        profileImage.rx.tapGesture()
            .when(.ended)
            .subscribe(with: self, onNext: { owner, _ in
                Log.kkr("프로필 이미지 변경")
            }).disposed(by: disposeBag)
        
        closeButton.rx.tapGesture()
            .when(.ended)
            .subscribe(with: self, onNext: { owner, _ in
                Log.kkr("Close popup")
                self.removeFromSuperview()
            }).disposed(by: disposeBag)
        
        createButton.rx.tapGesture()
            .when(.ended)
            .subscribe(onNext: { _ in
                Log.kkr("방 생성하기 버튼 클릭했음")
            }).disposed(by: disposeBag)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        self.endEditing(true)
    }
    
}

extension CreateRoomView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentTextLength = textView.text.count
        titleSizeLabel.text = "\(currentTextLength)/30"
        
        if currentTextLength > 30 {
            textView.text = String(textView.text.prefix(30))
            titleSizeLabel.text = "30/30"
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.snp.updateConstraints { make in
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.infinity))
            make.height.equalTo(size.height)
        }
    }

}
