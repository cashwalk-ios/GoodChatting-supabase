//
//  CodeIssuanceHistoryViewController.swift
//  GoodChatting
//
//  Created by Rocky on 2/1/24.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class CodeIssuanceHistoryViewController: BaseViewController, View {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    var tableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(hexCode: "F2F2F7")
        self.setView()
     
        guard let reactor = self.reactor else { return }
        bind(reactor: reactor)
    }
    
    // MARK: - Helpers
    
    func bind(reactor: CodeIssuanceHistoryReactor) {
        guard self.isViewLoaded else { return }
        self.bindAction(reactor: reactor)
        self.bindState(reactor: reactor)
    }
    
    // 완료 버튼 액션
    @objc private func doneAction() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Bind

extension CodeIssuanceHistoryViewController {
 
    private func bindAction(reactor: CodeIssuanceHistoryReactor) {


        
    }
    
    private func bindState(reactor: CodeIssuanceHistoryReactor) {
        
    }
    
}

// MARK: - Layout

extension CodeIssuanceHistoryViewController {
    
    private func setNavigation() {
        title = "코드 발급 기록"
        
        let doneButton = UIBarButtonItem(title: "완료", style: .done,
                                         target: self,
                                         action: #selector(self.doneAction))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func setView() {
        
        self.setNavigation()
        
        let codeIssuanceImageView = UIImageView().then {
            $0.image = UIImage(named: "codeIssuance_Image")
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.size.equalTo(150)
                $0.top.equalTo(69)
                $0.centerX.equalToSuperview()
            }
        }
        
        let description = UILabel().then {
            $0.text = "지난 참여 코드 발급 기록을 확인 및 삭제할 수 있습니다."
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = UIColor.init(hexCode: "6D6D71")
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(codeIssuanceImageView.snp.bottom).offset(9)
                $0.centerX.equalToSuperview()
            }
        }
        
        self.tableView = UITableView().then {
            $0.register(CodeIssuanceHistoryTableViewCell.self,
                        forCellReuseIdentifier: CodeIssuanceHistoryTableViewCell.cellIdentifier)
            $0.showsHorizontalScrollIndicator = false
            $0.clipsToBounds = true
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(description.snp.bottom).offset(45)
                $0.left.right.equalToSuperview().inset(15)
                $0.height.equalTo(240)
            }
        }
       
    }
    
}
