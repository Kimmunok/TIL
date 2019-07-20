//
//  SigninVewModel.swift
//  RxSwiftStudy
//
//  Created by 김문옥 on 21/07/2019.
//  Copyright © 2019 MunokKim. All rights reserved.
//

import RxSwift
import RxCocoa

class SigninViewModel {
    /* inputs */
    
    ///
    var emailDidChange = BehaviorRelay<String>(value: "")
    
    ///
    var passwordDidChange = BehaviorRelay<String>(value: "")
    
    /* outputs */
    
    ///
    func validateEmail(_ str: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: str)
    }
    
    ///
    func validatePassword(_ str: String, min: Int = 6, max: Int = 15) -> Bool {
        return (min...max).contains(str.count)
    }
}
