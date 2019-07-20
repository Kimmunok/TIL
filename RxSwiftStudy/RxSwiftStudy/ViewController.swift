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
    
//    var tv = UITableView()
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
}

