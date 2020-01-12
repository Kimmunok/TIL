//
//  ViewController.swift
//  RxSwiftStudy
//
//  Created by 김문옥 on 17/07/2019.
//  Copyright © 2019 MunokKim. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import SnapKit

import UIKit

class ViewController: UIViewController {
    
    let viewModel = SigninViewModel()
    
    var tv = UITableView()
    let tvData: [String] = ["Seoul", "New York", "London", "Tokyo", "Paris", "Moscow", "Beijing"]
    let reuseId = "MyCell"
//    let list = BehaviorRelay<[String]>(value: ["1", "2", "3", "4", "5"])
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    var signinButton = UIButton()
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        tv.frame = self.view.frame
//        self.view.addSubview(tv)
        
//        self.list.bind(to: tv.rx.items) { [weak self] tv, row, item in
//            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
//            if row != 5 {
//                cell.textLabel?.text = "\(item)"
//            } else {
//
//            }
//            return cell
//        }.disposed(by: disposeBag)
        
        configueUI()
        bindViewModel()
        configueTableView()
    }
    
    func configueUI() {
        emailTextField.placeholder = "email"
        passwordTextField.placeholder = "password"
        emailTextField.textAlignment = .center
        passwordTextField.textAlignment = .center
        emailTextField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        passwordTextField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        signinButton.setTitle("Sign in", for: .normal)
        signinButton.setTitleColor(UIColor.white, for: .normal)
        signinButton.setTitleColor(UIColor(red: 0.7, green: 0.7, blue: 1, alpha: 1.0), for: .disabled)
        signinButton.setTitleColor(UIColor(red: 0.7, green: 0.7, blue: 1, alpha: 1.0), for: .highlighted)
        signinButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1.0)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(signinButton)
        
        emailTextField.snp.makeConstraints { (m) in
            m.height.equalTo(50)
            m.leading.equalToSuperview().offset(30)
            m.trailing.equalToSuperview().offset(-30)
            m.centerY.equalToSuperview().multipliedBy(0.5)
            m.centerX.equalToSuperview()
        }
        passwordTextField.snp.makeConstraints { (m) in
            m.height.equalTo(0)
            m.leading.equalToSuperview().offset(30)
            m.trailing.equalToSuperview().offset(-30)
            m.top.equalTo(emailTextField.snp.bottom).offset(10)
            m.centerX.equalToSuperview()
        }
        signinButton.snp.makeConstraints { (m) in
            m.width.equalTo(100)
            m.height.equalTo(50)
            m.top.equalTo(passwordTextField.snp.bottom).offset(30)
            m.centerX.equalToSuperview()
        }
    }
    
    func bindViewModel() {
        /* inputs */
        
        // type email
        emailTextField.rx.text.orEmpty
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.emailDidChange)
            .disposed(by: disposeBag)
        
        // type password
        passwordTextField.rx.text.orEmpty
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.passwordDidChange)
            .disposed(by: disposeBag)
        
        // tap signin button
        signinButton.rx.tap
            .subscribe(onNext: { _ in print("Sign in successed.") })
            .disposed(by: disposeBag)
        
        /* outputs */
        
        // validEmail -> password field expend
        viewModel.emailDidChange
            .map(viewModel.validateEmail)
            .bind(to: passwordTextField.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.emailDidChange
            .map(viewModel.validateEmail)
            .asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] b in
                self?.passwordTextField.snp.updateConstraints({ (m) in
                    m.height.equalTo(b ? 50 : 0)
                })
                UIView.animate(withDuration: 0.5, animations: {
                    self?.view.layoutIfNeeded()
                })
            }).disposed(by: disposeBag)
        
        // validPassword -> signin button enable
        viewModel.passwordDidChange
            .map { self.viewModel.validatePassword($0) }
            .bind(to: signinButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    
    func configueTableView() {
        self.view.addSubview(tv)
        
        tv.snp.makeConstraints { (m) in
            m.leading.trailing.bottom.equalToSuperview()
            m.top.equalTo(signinButton.snp.bottom).offset(50)
        }
        
        tv.register(MyCell.self, forCellReuseIdentifier: reuseId)
        
        /*
         Bind the data to the tableView/collectionView using one of:
         
         1. rx.items(dataSource:protocol<RxTableViewDataSourceType, UITableViewDataSource>)
         2. rx.items(cellIdentifier:String)
         3. rx.items(cellIdentifier:String:Cell.Type:_:)
         4. rx.items(_:_:)
         */
        
        let dataOb: Observable<[String]> = Observable.of(tvData)
        
        // 1. tableView.rx.items 사용하기
//        dataOb
//            .bind(to: tv.rx.items) { (tv: UITableView, index: Int, element: String) -> UITableViewCell in
//                guard let cell = tv.dequeueReusableCell(withIdentifier: self.reuseId) else { return UITableViewCell() }
//                cell.textLabel?.text = element
//                return cell
//        }.disposed(by: disposeBag)
        
        // 2. tableView.rx.items(cellIdentifier:String) 사용하기
//        dataOb
//            .bind(to: tv.rx.items(cellIdentifier: reuseId)) { (index: Int, element: String, cell: UITableViewCell) in
//                cell.textLabel?.text = element
//        }.disposed(by: disposeBag)
        
        // 3. tableView.rx.items(cellIdentifier: String, cellType: Cell.Type) 사용하기
//        dataOb
//            .bind(to: tv.rx.items(cellIdentifier: reuseId, cellType: MyCell.self)) { (index: Int, element: String, cell: MyCell) in
//                cell.myLabel.text = "\(index) : \(element)"
//        }.disposed(by: disposeBag)
        
        // 4. tableView.rx.items(dataSource:protocol<RxTableViewDataSourceType, UITableViewDataSource>) 사용하기
        
        // 섹션 및 섹션타이틀 지정
        let sections = [
            SectionModel<String, String>(model: "First Section", items: tvData),
            SectionModel<String, String>(model: "Second Section", items: tvData)
        ]
        
//        let sectionOb = BehaviorSubject<[SectionModel]>(value: sections)
        let sectionOb = BehaviorRelay<[SectionModel]>(value: sections)

        // 섹션으로 스트림 시작
        sectionOb
            .bind(to: tv.rx.items(dataSource: myDataSource))
            .disposed(by: disposeBag)
        
        tv.rx.itemSelected
            .subscribe(onNext: { indexPath in
                var list = sectionOb.value
                list[indexPath.section].items.remove(at: indexPath.row)
                sectionOb.accept(list)
            }).disposed(by: disposeBag)
    }

    // 이름이 너무 긴 것을 Typealias를 통해 줄여줌
    typealias TvDataSectionModel = SectionModel<String, String>
    typealias TvDataDataSource = RxTableViewSectionedReloadDataSource<TvDataSectionModel>

    // datasource 만드는 부분을 프로퍼티로 빼줌
    private var myDataSource: TvDataDataSource {
        // SectionModel로 DataSource를 생성할 때 인자로 집어넣을 구성된 셀
        let configureCell: (TableViewSectionedDataSource<TvDataSectionModel>, UITableView, IndexPath, String) -> UITableViewCell = {
            (datasource, tableView, indexPath, element) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseId, for: indexPath) as? MyCell else { return UITableViewCell() }
            cell.myLabel.text = element
            cell.textLabel?.text = "\(indexPath.item) : \(element)"
            return cell
        }

        // RxTableViewSectionedReloadDataSource 생성
        let dataSource = TvDataDataSource.init(configureCell: configureCell)

        // 섹션타이틀 지정
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model
        }
        
        return dataSource
    }
}

class MyCell: UITableViewCell {
    
    var myLabel = UILabel()
    
    override func draw(_ rect: CGRect) {
        myLabel.frame = self.bounds
        myLabel.textColor = .blue
        myLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.0)
        myLabel.textAlignment = .center
        self.addSubview(myLabel)
    }
}
