//
//  JoinRoomView.swift
//  GoodChatting
//
//  Created by 김광록 on 2/4/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxGesture

final class JoinRoomView: UIView {
    var disposeBag = DisposeBag()
    var closeButton: UIView!
    var joinButton: UIView!
    var codeInputTextField: UITextField!
    var underline: UIView!
    var validView: UILabel!
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
            addSubview($0)
            $0.snp.makeConstraints { make in
                make.width.equalTo(321)
                make.height.equalTo(226)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().inset(287)
            }
        }
        
        let title = UILabel().then {
            $0.text = "채팅방 참여하기"
            $0.font = .appleSDGothicNeo(.bold, size: 16)
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(28)
                make.centerX.equalToSuperview()
            }
        }
        
        codeInputTextField = UITextField().then {
            $0.placeholder = "참여 코드를 입력해주세요."
            $0.font = .appleSDGothicNeo(.semiBold, size: 16)
            $0.delegate = self
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(title.snp.bottom).offset(47)
                make.left.right.equalToSuperview().inset(26)
            }
        }
        
        underline = UIView().then {
            $0.backgroundColor = .init(hexCode: "E0E0E0")
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(codeInputTextField.snp.bottom).offset(7)
                make.left.right.equalToSuperview().inset(22)
                make.height.equalTo(1)
            }
        }
        
        validView = UILabel().then {
            $0.text = "* 유효하지 않은 코드입니다."
            $0.font = .appleSDGothicNeo(.regular, size: 11)
            $0.textColor = .init(hexCode: "B2B2B2")
            $0.isHidden = true
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.top.equalTo(underline.snp.bottom).offset(8)
                make.left.equalToSuperview().inset(22)
            }
        }
        
        // 하단 버튼
        
        joinButton = UIView().then {
            $0.backgroundColor = .init(hexCode: "999999")
            $0.layer.cornerRadius = 8
            $0.isUserInteractionEnabled = false
            container.addSubview($0)
            $0.snp.makeConstraints { make in
                make.right.bottom.equalToSuperview().inset(20)
                make.width.equalTo(130)
                make.height.equalTo(48)
            }
        }
        
        _ = UILabel().then {
            $0.text = "참여하기"
            $0.textColor = .white
            $0.font = .appleSDGothicNeo(.semiBold, size: 16)
            joinButton.addSubview($0)
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
    }
    
    private func bindView() {
        closeButton.rx.tapGesture()
            .when(.ended)
            .subscribe(with: self, onNext: { owner, _ in
                owner.reactor?.action.onNext(.closePopupView(.join))
            }).disposed(by: disposeBag)
        
        joinButton.rx.tapGesture()
            .when(.ended)
            .filter { [weak self] _ in self?.codeInputTextField.text?.count ?? 0 > 0 }
            .observe(on: MainScheduler.instance)
            .flatMapLatest { [weak self] _ -> Observable<(Bool, Int)> in
                guard let self = self, let joinCode = self.codeInputTextField.text else {
                    return .just((false, 0))
                }
                return self.checkJoinCodeValidation(joinCode: joinCode)
                    .catchAndReturn((false, 0))
            }
            .subscribe(with: self, onNext: { owner, validData in
                let (isValid, roomId) = validData
                if isValid {
                    // 1. roomCYO라는 테이블에 people이라는 컬럼에 userId 추가
                    Task {
                        do {
                            try await self.addUserToRoom(userId: UserSettings.userId ?? "", roomId: roomId)
                            // TODO: 닉네임 생성해서 roomUserCYO에 추가 (addUserNickname() 메서드 사용)
                            let nickname = "유저#\(arc4random_uniform(1000))"
                            Log.kkr("생성된 닉네임: \(nickname)")
                            try await ChattingListManager.shared.addUserNickname(
                                userId: UserSettings.userId ?? "",
                                roomId: roomId,
                                nickName: nickname
                            )
                        } catch {
                            Log.kkr("방에 유저 추가 실패: \(error)")
                            GlobalFunctions.showToast(message: "\(error.localizedDescription)")
                        }
                    }
                    owner.reactor?.action.onNext(.closePopupView(.join))
                    // TODO: 참여한 방으로 이동하기 또는 홈 화면에 "참여한 채팅방" 목록 갱신하기
                } else {
                    // 참여코드가 roomCYO DB에 없는 경우
                    owner.validView.isHidden = false
                    GlobalFunctions.shake(owner.validView)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 참여코드 유효성 검사 후 Observable로 반환
    private func checkJoinCodeValidation(joinCode: String) -> Observable<(Bool, Int)> {
        return Observable.create { [weak self] observer in
            Task {
                do {
                    let isValid = try await self?.selectJoinCode(code: joinCode) ?? (false, 0)
                    observer.onNext(isValid)
                    observer.onCompleted()
                } catch {
                    Log.kkr("error: \(error.localizedDescription)")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    /// 입력한 참여코드가 roomCYO에 존재하는지 체크
    private func selectJoinCode(code: String) async throws -> (Bool, Int) {
        let response: [ChattingList] = try await AuthManager.shared.client.database
            .from("roomCYO")
            .select("*")
            .eq("active_participation_code", value: code)
            .execute()
            .value
        
        Log.kkr("참여코드 유효성 검사 결과: \(!response.isEmpty), id: \(response)")
        guard let id = response.first?.id else { return (false, 0) }
        return ((!response.isEmpty), id)
    }
    
    /// 참여코드가 유효한 경우 방에 참여하고 해당 채팅방에 people에 내 userId 갱신
    private func addUserToRoom(userId: String, roomId: Int) async throws {
        Log.kkr("참여한 방 id: \(roomId), 유저 id: \(userId)")
        // 현재 roomCYO 테이블의 people 컬럼 값을 가져옴
        let response: [ChattingList] = try await AuthManager.shared.client.database
            .from("roomCYO")
            .select("*")  // FIXME: 왜 여기서 people만 조회하면 안되는거야..?
            .eq("id", value: roomId)
            .execute()
            .value
        
        guard let currentPeopleArray = response.first?.people else { return }
        Log.kkr("currentPeopleArray: \(currentPeopleArray)")

        // 기존 people 배열에 userId가 존재하지 않는 경우에만 추가
        if !currentPeopleArray.contains(userId) {
            var newPeopleArray = currentPeopleArray
            newPeopleArray.append(userId)
            
            // people 컬럼 업데이트
            try await AuthManager.shared.client.database
                .from("roomCYO")
                .update(["people": newPeopleArray])
                .eq("id", value: roomId)
                .execute()
        } else {
            GlobalFunctions.showToast(message: "이미 참여한 방의 코드입니다.")
        }
    }

    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        self.endEditing(true)
    }
    
}

extension JoinRoomView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        underline.backgroundColor = .init(hexCode: "5BD6FF")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        underline.backgroundColor = .init(hexCode: "E0E0E0")
        textField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let textCnt = textField.text?.count ?? 0
        setButtonState(isEnabled: textCnt > 0)
    }
    
    private func setButtonState(isEnabled: Bool) {
        joinButton.isUserInteractionEnabled = isEnabled
        if isEnabled {
            joinButton.backgroundColor = .init(hexCode: "5BD6FF")
        } else {
            joinButton.backgroundColor = .init(hexCode: "999999")
        }
    }

}
