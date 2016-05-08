//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Martin Mandl on 08.05.16.
//  Copyright © 2016 m2m server software gmbh. All rights reserved.
//

import XCTest

class CalculatorTests: XCTestCase {
    
    func testDescription() {
        
        // a. touching 7 + would show “7 + ...” (with 7 still in the display)
        let brain = CalculatorBrain()
        brain.setOperand(7)
        brain.performOperation("+")
        XCTAssertEqual(brain.description, "7 + ")
        XCTAssertTrue(brain.isPartialResult)
        XCTAssertEqual(brain.result, 7.0)
        
        // b. 7 + 9 would show “7 + ...” (9 in the display)
        //brain.setOperand(9) // entered but not pushed to model
        XCTAssertEqual(brain.description, "7 + ")
        XCTAssertTrue(brain.isPartialResult)
        XCTAssertEqual(brain.result, 7.0)
        
        // c. 7 + 9 = would show “7 + 9 =” (16 in the display)
        brain.setOperand(9)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "7 + 9")
        XCTAssertFalse(brain.isPartialResult)
        XCTAssertEqual(brain.result, 16.0)

        // d. 7 + 9 = √ would show “√(7 + 9) =” (4 in the display)
        brain.performOperation("√")
        XCTAssertEqual(brain.description, "√(7 + 9)")
        XCTAssertFalse(brain.isPartialResult)
        XCTAssertEqual(brain.result, 4.0)
        
        // e. 7 + 9 √ would show “7 + √(9) ...” (3 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("√")
        XCTAssertEqual(brain.description, "7 + √(9)")
        XCTAssertTrue(brain.isPartialResult)
        XCTAssertEqual(brain.result, 3.0)
        
        // f. 7 + 9 √ = would show “7 + √(9) =“ (10 in the display)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "7 + √(9)")
        XCTAssertFalse(brain.isPartialResult)
        XCTAssertEqual(brain.result, 10.0)
        
        // g. 7 + 9 = + 6 + 3 = would show “7 + 9 + 6 + 3 =” (25 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("=")
        brain.performOperation("+")
        brain.setOperand(6)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "7 + 9 + 6 + 3")
        XCTAssertFalse(brain.isPartialResult)
        XCTAssertEqual(brain.result, 25.0)
        
        // h. 7 + 9 = √ 6 + 3 = would show “6 + 3 =” (9 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.setOperand(9)
        brain.performOperation("=")
        brain.performOperation("√")
        brain.setOperand(6)
        brain.performOperation("+")
        brain.setOperand(3)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "6 + 3")
        XCTAssertFalse(brain.isPartialResult)
        XCTAssertEqual(brain.result, 9.0)
        
        // i. 5 + 6 = 7 3 would show “5 + 6 =” (73 in the display)
        brain.setOperand(5)
        brain.performOperation("+")
        brain.setOperand(6)
        brain.performOperation("=")
        //brain.setOperand(73) // entered but not pushed to model
        XCTAssertEqual(brain.description, "5 + 6")
        XCTAssertFalse(brain.isPartialResult)
        XCTAssertEqual(brain.result, 11.0)
        
        // j. 7 + = would show “7 + 7 =” (14 in the display)
        brain.setOperand(7)
        brain.performOperation("+")
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "7 + 7")
        XCTAssertFalse(brain.isPartialResult)
        XCTAssertEqual(brain.result, 14.0)
        
        // k. 4 × π = would show “4 × π =“ (12.5663706143592 in the display)
        brain.setOperand(4)
        brain.performOperation("×")
        brain.performOperation("π")
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "4 × π")
        XCTAssertFalse(brain.isPartialResult)
        XCTAssertTrue(abs(brain.result - 12.5663706143592) < 0.001)
        
        // m. 4 + 5 × 3 = could also show “(4 + 5) × 3 =” if you prefer (27 in the display)
        brain.setOperand(4)
        brain.performOperation("+")
        brain.setOperand(5)
        brain.performOperation("×")
        brain.setOperand(3)
        brain.performOperation("=")
        XCTAssertEqual(brain.description, "(4 + 5) × 3")
        XCTAssertFalse(brain.isPartialResult)
        XCTAssertEqual(brain.result, 27.0)

    }
    
}
