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
    
    @IBOutlet private weak var history: UILabel!
    
    private var userIsInTheMiddleOfTyping = false {
        didSet {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfFloatingPointNummer = false
            }
        }
    }
    private var userIsInTheMiddleOfFloatingPointNummer = false
    
    private let decimalSeparator = NSNumberFormatter().decimalSeparator!
    
    private struct Constants {
        static let DecimalDigits = 6
    }
    
    
    @IBAction private func touchDigit(sender: UIButton) {
        var digit = sender.currentTitle!
        
        if digit == decimalSeparator {
            if userIsInTheMiddleOfFloatingPointNummer {
                return
            }
            if !userIsInTheMiddleOfTyping {
                digit = "0" + decimalSeparator
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
    
    private var displayValue: Double? {
        get {
            if let text = display.text, value = NSNumberFormatter().numberFromString(text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.maximumFractionDigits = Constants.DecimalDigits
                display.text = formatter.stringFromNumber(value)
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
            } else {
                display.text = "0"
                history.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    private var brain = CalculatorBrain(decimalDigits: Constants.DecimalDigits)
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
    
    @IBAction func backSpace(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if var text = display.text {
                text.removeAtIndex(text.endIndex.predecessor())
                if text.isEmpty {
                    text = "0"
                    userIsInTheMiddleOfTyping = false
                }
                display.text = text
            }
        }
    }
    
    @IBAction func clearEverything(sender: UIButton) {
        brain = CalculatorBrain(decimalDigits: Constants.DecimalDigits)
        displayValue = nil
    }
    
    private func adjustButtonLayout(view: UIView, portrait: Bool) {
        for subview in view.subviews {
            if subview.tag == 1 {
                subview.hidden = portrait
            } else if subview.tag == 2 {
                subview.hidden = !portrait
            }
            if let button = subview as? UIButton {
                button.setBackgroundColor(UIColor.blackColor(), forState: .Highlighted)
                if button.tag == 3 {
                    button.setTitle(decimalSeparator, forState: .Normal)
                }
            } else if let stack = subview as? UIStackView {
                adjustButtonLayout(stack, portrait: portrait);
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustButtonLayout(view, portrait: traitCollection.horizontalSizeClass == .Compact && traitCollection.verticalSizeClass == .Regular)
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        adjustButtonLayout(view, portrait: newCollection.horizontalSizeClass == .Compact && newCollection.verticalSizeClass == .Regular)
    }
    
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState state: UIControlState) {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext();
        color.setFill()
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(image, forState: state);
    }
}

