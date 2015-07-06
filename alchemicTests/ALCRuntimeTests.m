//
//  ALCRuntimeTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import <Alchemic/Alchemic.h>
#import "ALCRuntime.h"

@interface ALCRuntimeTests : XCTestCase

@end

@implementation ALCRuntimeTests

#pragma mark - Type checks

-(void) testObjectIsAClassWithStringClass {
    XCTAssertTrue([ALCRuntime objectIsAClass:[NSString class]]);
}

-(void) testObjectIsAClassWithOtherClass {
    XCTAssertTrue([ALCRuntime objectIsAClass:[NSNumber class]]);
}

-(void) testObjectIsAClassWithProtocol {
    XCTAssertFalse([ALCRuntime objectIsAClass:@protocol(NSCopying)]);
}

-(void) testObjectIsAClassWithStringObject {
    XCTAssertFalse([ALCRuntime objectIsAClass:@"abc"]);
}

-(void) testObjectIsAClassWithNumberObject {
    XCTAssertFalse([ALCRuntime objectIsAClass:@12]);
}

-(void) testObjectIsAProtocolWithStringClass {
    XCTAssertFalse([ALCRuntime objectIsAProtocol:[NSString class]]);
}

-(void) testObjectIsAProtocolWithOtherClass {
    XCTAssertFalse([ALCRuntime objectIsAProtocol:[NSNumber class]]);
}

-(void) testObjectIsAProtocolWithProtocol {
    XCTAssertTrue([ALCRuntime objectIsAProtocol:@protocol(NSCopying)]);
}

-(void) testObjectIsAProtocolWithStringObject {
    XCTAssertFalse([ALCRuntime objectIsAProtocol:@"abc"]);
}

-(void) testObjectIsAProtocolWithNumberObject {
    XCTAssertFalse([ALCRuntime objectIsAProtocol:@12]);
}

-(void) testClassIsKindOfClassStringString {
    XCTAssertTrue([ALCRuntime class:[NSString class] isKindOfClass:[NSString class]]);
}

-(void) testClassIsKindOfClassMutableStringString {
    XCTAssertTrue([ALCRuntime class:[NSMutableString class] isKindOfClass:[NSString class]]);
}

-(void) testClassIsKindOfClassStringMutableString {
    XCTAssertFalse([ALCRuntime class:[NSString class] isKindOfClass:[NSMutableString class]]);
}

-(void) testClassConformsToProtocolWhenConforming {
    XCTAssertTrue([ALCRuntime class:[NSString class] conformsToProtocol:@protocol(NSCopying)]);
}

-(void) testClassConformsToProtocolWhenNotConforming {
    XCTAssertFalse([ALCRuntime class:[NSString class] conformsToProtocol:@protocol(NSFastEnumeration)]);
}

#pragma mark - General

-(void) testAlchemicSelector {
    SEL alcSel = [ALCRuntime alchemicSelectorForSelector:@selector(testAlchemicSelector)];
    XCTAssertEqualObjects(@"_alchemic_testAlchemicSelector", NSStringFromSelector(alcSel));
}

@end
