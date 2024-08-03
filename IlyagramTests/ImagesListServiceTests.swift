//
//  IlyagramTests.swift
//  IlyagramTests
//
//  Created by Ilya Shirokov on 29.07.2024.
//

import XCTest
@testable import Ilyagram

final class IlyagramTests: XCTestCase {

    func testExample() throws {
        let service = ImageListService()
                
                let expectation = self.expectation(description: "Wait for Notification")
                NotificationCenter.default.addObserver(
                    forName: ImageListService.didChangeNotification,
                    object: nil,
                    queue: .main) { _ in
                        expectation.fulfill()
                    }
                
                service.fetchPhotosNextPage()
                wait(for: [expectation], timeout: 10)
                
                XCTAssertEqual(service.photos.count, 10)
    }
}
