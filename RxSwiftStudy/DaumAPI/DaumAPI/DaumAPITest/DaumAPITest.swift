//
//  DaumAPITest.swift
//  DaumAPITest
//
//  Created by ByoungHoon Yun on 21/07/2019.
//  Copyright © 2019 ByoungHoon. All rights reserved.
//

import XCTest
import DaumAPI

class DaumAPITest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
//        daumAPITest()
    }
    
    func testDaumAPI() {
        
        let promise = expectation(description: "Completion handler invoked")
        
        let provider = Provider<API>()
        
        var statusCode: Int?
        var responseError: Error?
        
        let parameters: SearchParameters = (query: "일요일", sort: nil, page: nil, size: nil)
        
        provider.request(API.searchForImage(parameters:parameters)) { (result) in
            
            switch result {
            case .success(let result):

                statusCode = (result.urlResponse as? HTTPURLResponse)?.statusCode
                promise.fulfill()
                print(result.data)
                
            case .failure(let fail):
                responseError = fail
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
        
    }


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


extension DaumAPITest {
    
    
}
