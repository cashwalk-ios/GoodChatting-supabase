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
    
    var expiredCodeListTableView: UITableView!
    
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
        
        reactor.state.map { $0.tempExpiredCodeList }
            .bind(to: expiredCodeListTableView.rx.items(cellIdentifier: CodeIssuanceHistoryTableViewCell.cellIdentifier, cellType: CodeIssuanceHistoryTableViewCell.self)) { row, item, cell in
                cell.configureCell(count: row + 1, code: reactor.currentState.tempExpiredCodeList[row])
            }.disposed(by: disposeBag)
        
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
        
        let scrollView = UIScrollView().then {
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = UIColor.init(hexCode: "000000")
            self.view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
                $0.left.right.equalToSuperview()
            }
        }
        
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 45
            $0.backgroundColor = UIColor.init(hexCode: "F2F2F7")
            scrollView.addSubview($0)
            $0.snp.makeConstraints {
                $0.width.equalTo(self.view)
                $0.edges.equalToSuperview()
            }
        }
        
        let codeIssuanceImageView = UIImageView().then {
            $0.image = UIImage(named: "codeIssuance_Image")
            $0.snp.makeConstraints {
                $0.size.equalTo(150)
            }
        }
        
        let description = UILabel().then {
            $0.text = "지난 참여 코드 발급 기록을 확인 및 삭제할 수 있습니다."
            $0.font = .appleSDGothicNeo(.regular, size: 12)
            $0.textColor = UIColor.init(hexCode: "6D6D71")
        }
        
        let headerStackView = UIStackView(arrangedSubviews: [codeIssuanceImageView, description]).then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 9
            stackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().offset(14)
            }
        }
        
        self.expiredCodeListTableView = UITableView(frame: .zero, style: .plain).then {
            $0.register(CodeIssuanceHistoryTableViewCell.self,
                        forCellReuseIdentifier: CodeIssuanceHistoryTableViewCell.cellIdentifier)
            $0.isScrollEnabled = false
            $0.backgroundColor = .designColor(color: .white())
            $0.layer.cornerRadius = 10
            let rowHeight = 57
            $0.rowHeight = CGFloat(rowHeight)
            $0.clipsToBounds = true
            stackView.addArrangedSubview($0)
            $0.snp.makeConstraints {
                guard let reactor else { return }
                $0.left.right.equalToSuperview().inset(15)
                $0.height.equalTo(reactor.currentState.tempExpiredCodeList.count * rowHeight)
            }
        }
       
    }
    
}
