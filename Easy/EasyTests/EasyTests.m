//
//  EasyTests.m
//  EasyTests
//
//  Created by Jayce Yang on 13-12-13.
//  Copyright (c) 2013年 Jayce Yang. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface EasyTests : XCTestCase

@end

@implementation EasyTests

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

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
