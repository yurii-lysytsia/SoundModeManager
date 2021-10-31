// Copyright © 2021 Yurii Lysytsia. All rights reserved.

import XCTest
@testable import SoundModeManager

final class SoundModeManagerTests: XCTestCase {
    
    // MARK: - Private Properties
    
    private var sut: SoundModeManager!
    private var observationToken: SoundModeManager.ObservationToken?
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        sut = SoundModeManager()
        
        // Check default mode before each tests.
        XCTAssertEqual(sut.currentMode, .notDetermined)
    }
    
    // MARK: - Tests
    
    func testUpdateCurrentMode() {
        // Update current mode once
        let expectation = XCTestExpectation(description: "Update current mode once")
        sut.updateCurrentMode { mode in
            XCTAssertNotEqual(mode, .notDetermined)
            
            // Check is block will be called in the second time
            self.sut.updateCurrentMode { newMode in
                XCTAssertEqual(newMode, mode)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    
    func testCurrentModeObserver() {
        let expectation = XCTestExpectation(description: "Update current mode when it changes")
        observationToken = sut.observeCurrentMode { mode in
            XCTAssertNotEqual(mode, .notDetermined)
            expectation.fulfill()
        }
        sut.beginUpdatingCurrentMode()
        wait(for: [expectation], timeout: 10)
    }

}
