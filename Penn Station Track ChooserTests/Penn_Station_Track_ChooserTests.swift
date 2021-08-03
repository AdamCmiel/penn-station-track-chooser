//
//  Penn_Station_Track_ChooserTests.swift
//  Penn Station Track ChooserTests
//
//  Created by Adam Cmiel on 5/10/20.
//  Copyright © 2020 Adam Cmiel. All rights reserved.
//

import XCTest
import CodableCSV
@testable import Penn_Station_Track_Chooser

class Penn_Station_Track_ChooserTests: XCTestCase {

    func testStationDataDecoding() {
        XCTAssertGreaterThan(StationData.allData.count, 0)
    }

}
