//
//  YT_Minia_MakerTests.swift
//  YT Minia MakerTests
//
//  Created by Nicolas Bachur on 28/04/2024.
//

import XCTest
@testable import YT_Minia_Maker

extension Int {
    var toDouble: Double {
        Double(self)
    }
}

final class YT_Minia_MakerTests: XCTestCase {
    lazy var sec: Int = 1
    lazy var min: Int = sec * 60
    lazy var hour: Int = min * 60
    lazy var day: Int = hour * 24
    lazy var week: Int = day * 7
    lazy var month: Int = day * 31
    lazy var year: Int = week * 52

    func testPublicationDateFormatter() throws {
        let sec1 = sec
        let sec10 = sec1 * 10
        let min1 = min + 1
        let min10 = min1 * 10
        let hour1 = hour
        let hour2 = hour1 * 2
        let day1 = day
        let day4 = day1 * 4
        let week1 = week
        let week2 = week1 * 2
        let month1 = month
        let month6 = month1 * 6
        let year1 = month * 12
        let year5 = year1 * 5

        XCTAssertEqual(Date(timeIntervalSinceNow: -sec1.toDouble).formatPublicationDate(),  String(localized: "1 second ago"))
        XCTAssertEqual(Date(timeIntervalSinceNow: -sec10.toDouble).formatPublicationDate(),  String(localized: "10 seconds ago"))
        
        XCTAssertEqual(Date(timeIntervalSinceNow: -min1.toDouble).formatPublicationDate(),  String(localized: "1 minute ago"))
        XCTAssertEqual(Date(timeIntervalSinceNow: -min10.toDouble).formatPublicationDate(),  String(localized: "10 minutes ago"))
        
        XCTAssertEqual(Date(timeIntervalSinceNow: -hour1.toDouble).formatPublicationDate(),  String(localized: "1 hour ago"))
        XCTAssertEqual(Date(timeIntervalSinceNow: -hour2.toDouble).formatPublicationDate(),  String(localized: "2 hours ago"))
        
        XCTAssertEqual(Date(timeIntervalSinceNow: -day1.toDouble).formatPublicationDate(),  String(localized: "1 day ago"))
        XCTAssertEqual(Date(timeIntervalSinceNow: -day4.toDouble).formatPublicationDate(),  String(localized: "4 days ago"))
        
        XCTAssertEqual(Date(timeIntervalSinceNow: -week1.toDouble).formatPublicationDate(),  String(localized: "1 week ago"))
        XCTAssertEqual(Date(timeIntervalSinceNow: -week2.toDouble).formatPublicationDate(),  String(localized: "2 weeks ago"))
        
        XCTAssertEqual(Date(timeIntervalSinceNow: -month1.toDouble).formatPublicationDate(),  String(localized: "1 month ago"))
        XCTAssertEqual(Date(timeIntervalSinceNow: -month6.toDouble).formatPublicationDate(),  String(localized: "6 months ago"))
        
        XCTAssertEqual(Date(timeIntervalSinceNow: -year1.toDouble).formatPublicationDate(),  String(localized: "1 year ago"))
        XCTAssertEqual(Date(timeIntervalSinceNow: -year5.toDouble).formatPublicationDate(),  String(localized: "5 years ago"))
    }
    
    func testViewCount() throws {
        let nan = "hello"
        
        let count1 = "10"
        let count2 = "100"
        let count3 = "1000"
        let count4 = "10000"
        let count5 = "100000"
        let count6 = "1000000"
        let count7 = "10000000"
        let count8 = "100000000"
        
        XCTAssertEqual(nan.formatViewCount(),  String(localized: "!Invalid Number"))
        
        XCTAssertEqual(count1.formatViewCount(),  String(localized: "10 views"))
        XCTAssertEqual(count2.formatViewCount(),  String(localized: "100 views"))
        XCTAssertEqual(count3.formatViewCount(),  String(localized: "1 k views"))
        XCTAssertEqual(count4.formatViewCount(),  String(localized: "10 k views"))
        XCTAssertEqual(count5.formatViewCount(),  String(localized: "100 k views"))
        XCTAssertEqual(count6.formatViewCount(),  String(localized: "1 m views"))
        XCTAssertEqual(count7.formatViewCount(),  String(localized: "10 m views"))
        XCTAssertEqual(count8.formatViewCount(),  String(localized: "100 m views"))
    }
    
    func testChannelCount() throws {
        let nan = "hello"
        
        let count1 = "10"
        let count2 = "100"
        let count3 = "1000"
        let count4 = "10000"
        let count5 = "100000"
        let count6 = "1000000"
        let count7 = "10000000"
        let count8 = "100000000"
        
        XCTAssertEqual(nan.formatViewCount(),  String(localized: "!Invalid Number"))
        
        XCTAssertEqual(count1.formatChannelCount(),  String(localized: "10 subscribers"))
        XCTAssertEqual(count2.formatChannelCount(),  String(localized: "100 subscribers"))
        XCTAssertEqual(count3.formatChannelCount(),  String(localized: "1 k subscribers"))
        XCTAssertEqual(count4.formatChannelCount(),  String(localized: "10 k subscribers"))
        XCTAssertEqual(count5.formatChannelCount(),  String(localized: "100 k subscribers"))
        XCTAssertEqual(count6.formatChannelCount(),  String(localized: "1 m subscribers"))
        XCTAssertEqual(count7.formatChannelCount(),  String(localized: "10 m subscribers"))
        XCTAssertEqual(count8.formatChannelCount(),  String(localized: "100 m subscribers"))
    }
    
    func testVideoDuration() throws {
        let d1 = "PT15S"
        let d2 = "PT1M"
        let d22 = "PT1M00S"
        let d3 = "PT1M15S"
        let d4 = "PT10M15S"
        let d5 = "PT1H00M"
        let d6 = "PT1H10M"
        let d7 = "PT2H10M"
        let d8 = "PT2H10M15S"
        
        XCTAssertEqual(d1.formattedVideoDuration(),  String(localized: "00:15"))
        XCTAssertEqual(d2.formattedVideoDuration(),  String(localized: "01:00"))
        XCTAssertEqual(d22.formattedVideoDuration(),  String(localized: "01:00"))
        XCTAssertEqual(d3.formattedVideoDuration(),  String(localized: "01:15"))
        XCTAssertEqual(d4.formattedVideoDuration(),  String(localized: "10:15"))
        XCTAssertEqual(d5.formattedVideoDuration(),  String(localized: "01:00:00"))
        XCTAssertEqual(d6.formattedVideoDuration(),  String(localized: "01:10:00"))
        XCTAssertEqual(d7.formattedVideoDuration(),  String(localized: "02:10:00"))
        XCTAssertEqual(d8.formattedVideoDuration(),  String(localized: "02:10:15"))
    }
}
