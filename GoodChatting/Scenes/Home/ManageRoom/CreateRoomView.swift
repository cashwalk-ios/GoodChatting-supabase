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
    var chatRoomTitle: UITextField!
    var underline: UIView!
    var titleSizeLabel: UILabel!
    var reactor: HomeReactor?

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
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(215)
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
            $0.backgroundColor = .init(hexCode: "999999")
            $0.layer.cornerRadius = 8
            $0.isUserInteractionEnabled = false
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(22)
                make.bottom.equalToSuperview().inset(21)
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
                make.left.equalToSuperview().inset(22)
                make.bottom.equalToSuperview().inset(21)
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
        
        underline = UIView().then {
            $0.backgroundColor = .init(hexCode: "E0E0E0")
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(22)
                make.height.equalTo(1)
                make.bottom.equalTo(closeButton.snp.top).offset(-51)
            }
        }
        titleSizeLabel = UILabel().then {
            $0.text = "0/30"
            $0.textColor = .init(hexCode: "B2B2B2")
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(22)
                make.bottom.equalTo(underline.snp.top).offset(-6)
            }
        }
        
        chatRoomTitle = UITextField().then {
            $0.placeholder = "채팅방 이름을 입력해주세요."
            $0.font = .appleSDGothicNeo(.semiBold, size: 16)
            $0.delegate = self
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(26)
                make.right.equalTo(titleSizeLabel.snp.left).offset(-5)
                make.bottom.equalTo(underline.snp.top).offset(-7)
            }
        }
        
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
                owner.reactor?.action.onNext(.closePopupView(.create(nil)))
            }).disposed(by: disposeBag)
        
        createButton.rx.tapGesture()
            .when(.ended)
            .filter { [weak self] _ in self?.chatRoomTitle.text?.count ?? 0 > 0 }
            .subscribe(with: self, onNext: { owner, _ in
                // TODO: 방 생성 로직 추가해야 함
//                Task {
//                    try await ChattingListManager.shared.addChattingTable(testNum: currentState.chattingList.count)
//                }
                // 유저테이블에 만든 방 id를 넣어야 함
                
                let title = owner.chatRoomTitle.text ?? ""
                let addItem = ChattingRoomItem(title: title,            //채팅방 이름
                                               image: "template01",               //채팅방 썸네일 이미지 - 없어도됨 없을떈 nil
                                               maker: 1,                //생성자 id
                                               people: [1],             //채팅방 만들떄는 참여인원은 생성자 하나뿐이니 생성자 아이디를 어레이에 담아서 전달
                                               updated_at: Date())      //고정값
                
                owner.reactor?.action.onNext(.closePopupView(.create(addItem)))
            }).disposed(by: disposeBag)
        
        chatRoomTitle.rx.text
            .changed
            .bind(with: self, onNext: { owner, title in
                owner.titleSizeLabel.text = "\(title?.count ?? 0)/30"
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

extension CreateRoomView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        underline.backgroundColor = .init(hexCode: "5BD6FF")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        underline.backgroundColor = .init(hexCode: "E0E0E0")
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 30
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let textCnt = textField.text?.count ?? 0
        setButtonState(isEnabled: textCnt > 0)
    }
    
    private func setButtonState(isEnabled: Bool) {
        createButton.isUserInteractionEnabled = isEnabled
        if isEnabled {
            createButton.backgroundColor = .init(hexCode: "5BD6FF")
        } else {
            createButton.backgroundColor = .init(hexCode: "999999")
        }
    }
}
