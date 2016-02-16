//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCContext.h"
#import "ALCContextImpl.h"
#import "ALCObjectFactory.h"
#import "ALCClassObjectFactory.h"

@interface Singleton : NSObject
@end

@implementation Singleton
@end

@interface Instantiations : XCTestCase
@end

@implementation Instantiations

-(void) testInstantiation {

    id<ALCContext> context = [[ALCContextImpl alloc] init];
    ALCClassObjectFactory *valueFactory = [context registerClass:[Singleton class]];
    [context start];

    XCTAssertTrue(valueFactory.ready);

    id value = valueFactory.object;
    XCTAssertTrue([value isKindOfClass:[Singleton class]]);
}

@end