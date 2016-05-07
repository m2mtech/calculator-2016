//
//  ViewController.swift
//  Calculator
//
//  Created by Martin Mandl on 05.05.16.
//  Copyright © 2016 m2m server software gmbh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false {
        didSet {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfFloatingPointNummer = false
            }
        }
    }
    private var userIsInTheMiddleOfFloatingPointNummer = false
    
    @IBAction private func touchDigit(sender: UIButton) {
        var digit = sender.currentTitle!
        
        if digit == "." {
            if userIsInTheMiddleOfFloatingPointNummer {
                return
            }
            if !userIsInTheMiddleOfTyping {
                digit = "0."
            }
            userIsInTheMiddleOfFloatingPointNummer = true
        }
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
    
}

