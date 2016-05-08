//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Martin Mandl on 06.05.16.
//  Copyright © 2016 m2m server software gmbh. All rights reserved.
//

import Foundation

func factorial(op1: Double) -> Double {
    if (op1 <= 1) {
        return 1
    }
    return op1 * factorial(op1 - 1.0)
}

class CalculatorBrain {
    private var accumulator = 0.0
    
    func setOperand(operand: Double) {
        accumulator = operand
        descriptionAccumulator = String(format:"%g", operand)
    }
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({ -$0 }, { "-(" + $0 + ")"}),
        "√" : Operation.UnaryOperation(sqrt, { "√(" + $0 + ")"}),
        "x²" : Operation.UnaryOperation({ pow($0, 2) }, { "(" + $0 + ")²"}),
        "x³" : Operation.UnaryOperation({ pow($0, 3) }, { "(" + $0 + ")³"}),
        "x⁻¹" : Operation.UnaryOperation({ 1 / $0 }, { "(" + $0 + ")⁻¹"}),
        "sin" : Operation.UnaryOperation(sin, { "sin(" + $0 + ")"}),
        "cos" : Operation.UnaryOperation(cos, { "cos(" + $0 + ")"}),
        "tan" : Operation.UnaryOperation(tan, { "tan(" + $0 + ")"}),
        "sinh" : Operation.UnaryOperation(sinh, { "sinh(" + $0 + ")"}),
        "cosh" : Operation.UnaryOperation(cosh, { "cosh(" + $0 + ")"}),
        "tanh" : Operation.UnaryOperation(tanh, { "tanh(" + $0 + ")"}),
        "ln" : Operation.UnaryOperation(log, { "ln(" + $0 + ")"}),
        "log" : Operation.UnaryOperation(log10, { "log(" + $0 + ")"}),
        "eˣ" : Operation.UnaryOperation(exp, { "e^(" + $0 + ")"}),
        "10ˣ" : Operation.UnaryOperation({ pow(10, $0) }, { "10^(" + $0 + ")"}),
        "x!" : Operation.UnaryOperation(factorial, { "(" + $0 + ")!"}),
        "×" : Operation.BinaryOperation(*, { $0 + " × " + $1 }, 1),
        "÷" : Operation.BinaryOperation(/, { $0 + " ÷ " + $1 }, 1),
        "+" : Operation.BinaryOperation(+, { $0 + " + " + $1 }, 0),
        "-" : Operation.BinaryOperation(-, { $0 + " - " + $1 }, 0),
        "xʸ" : Operation.BinaryOperation(pow, { $0 + " ^ " + $1 }, 2),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case Equals        
    }
    
    private var currentPrecedence = Int.max
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}