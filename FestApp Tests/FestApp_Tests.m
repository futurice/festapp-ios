//
//  FestApp_Tests.m
//  FestApp Tests
//
//  Created by Sami Saada on 11.04.2014.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FestApp.h"

@interface FestApp_Tests : XCTestCase

@end

@implementation FestApp_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testResourceBaseUrlIsCorrect
{
    XCTAssertEqual(kResourceBaseUrl, @"http://festapp-server.herokuapp.com");
}

@end
