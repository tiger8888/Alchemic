//
//  ALCExternalStorageTests.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCBuilderStorageExternal.h"

@interface ALCBuilderStorageExternalTests : XCTestCase

@end

@implementation ALCBuilderStorageExternalTests

-(void) testNoValue {
    ALCBuilderStorageExternal *storage = [[ALCBuilderStorageExternal alloc] init];
    XCTAssertThrowsSpecificNamed([storage value], NSException, @"AlchemicCannotCreateValue");
    XCTAssertFalse(storage.hasValue);
}

-(void) testStoresValues {
    ALCBuilderStorageExternal *storage = [[ALCBuilderStorageExternal alloc] init];
    storage.value = @"abc";
    XCTAssertEqualObjects(@"abc", storage.value);
    XCTAssertTrue(storage.hasValue);
}

-(void) testIsReadyWhenHasValue {
    ALCBuilderStorageExternal *storage = [[ALCBuilderStorageExternal alloc] init];
    storage.value = @"abc";
    XCTAssertTrue(storage.ready);
}

-(void) testIsNotReadyWhenNoValue {
    ALCBuilderStorageExternal *storage = [[ALCBuilderStorageExternal alloc] init];
    XCTAssertFalse(storage.ready);
}

@end