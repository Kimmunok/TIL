 //
//  ViewController.swift
//  CalculatorApp
//
//  Created by 김문옥 on 2017. 7. 17..
//  Copyright © 2017년 김문옥. All rights reserved.
//

import UIKit

var calculatorCount = 0

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    
    private var userTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatorCount += 1
        print("새로운 계산기가 로드 되었습니다 (count = \(calculatorCount))")
        brain.addUnaryOperation(symbol: "Z") { [ weak weakSelf = self ] in
            weakSelf?.display.textColor = UIColor.red
            return sqrt($0)
        }
    }
    
    deinit {
        calculatorCount -= 1
        print("계산기가 힙에서 제거되었습니다 (count = \(calculatorCount))")
    }

    @IBAction private func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        if userTyping {
            let textCurrentlyInDisPlay = display.text!
            display.text = textCurrentlyInDisPlay + digit
        } else {
            display.text = digit
        }
        userTyping = true
    }
    
    private var displayValue:Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }

    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        
        if userTyping {
            brain.setOperand(operand: displayValue)
            userTyping = false
        }
        
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathSymbol)
        }
        
        displayValue = brain.result
    }
}

