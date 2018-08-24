//
//  CalculatorBrain.swift
//  CalculatorApp
//
//  Created by 김문옥 on 2017. 7. 18..
//  Copyright © 2017년 김문옥. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    
    func setOperand(operand:Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    func addUnaryOperation(symbol: String, operation: @escaping (Double) -> Double) {
        operations[symbol] = Operation.UnaryOperation(operation) 
    }
    
    private var operations:Dictionary<String,Operation> = [
        "∏" : Operation.Constant(.pi),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({ -$0 }),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "×" : Operation.BinaryOperation({ $0 * $1 }),
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol:String) {
        
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let associatedValue):
                accumulator = associatedValue
            case .UnaryOperation(let associatedFunction):
                accumulator = associatedFunction(accumulator)
            case .BinaryOperation(let associatedFunction):
                runWaitingBinaryOperation()
                waiting = WaitingBinaryOperationInfo(binaryFunction: associatedFunction, firstOperand: accumulator)
            case .Equals :
                runWaitingBinaryOperation()
            }
        }
    }
    
    private func runWaitingBinaryOperation() {
        if waiting != nil {
            accumulator = waiting!.binaryFunction(waiting!.firstOperand, accumulator)
            waiting = nil
        }
    }
    
    private var waiting:WaitingBinaryOperationInfo?
    
    private struct WaitingBinaryOperationInfo {
        var binaryFunction:(Double, Double) -> Double
        var firstOperand:Double
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        waiting = nil
        internalProgram.removeAll()
    }
    
    var result:Double {
        get {
            return accumulator
        }
    }
}
