//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <StoryTeller/StoryTeller.h>

#import <Alchemic/Alchemic.h>

//#import "ALCContextImpl.h"
//#import "ALCClassObjectFactory.h"

#import "TopThing.h"
#import "NestedThing.h"

@interface ClassInitializers : XCTestCase
@end

@implementation ClassInitializers {
    id<ALCContext> _context;
    ALCClassObjectFactory *_topThingFactory;
    ALCClassObjectFactory *_nestedThingFactory;
}

-(void) setUp {
    STStartLogging(@"[TopThing]");
    STStartLogging(@"[Alchemic]");
    _context = [[ALCContextImpl alloc] init];
    _topThingFactory = [_context registerObjectFactoryForClass:[TopThing class]];
    _nestedThingFactory = [_context registerObjectFactoryForClass:[NestedThing class]];
}

-(void) testInitializer {

    [_context objectFactory:_topThingFactory
                initializer:@selector(init), nil];
    [_context start];

    XCTAssertTrue(_topThingFactory.ready);

    id value = _topThingFactory.instantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
}

-(void) testInitializerWithString {

    [_context objectFactory:_topThingFactory
                initializer:@selector(initWithString:), AcString(@"abc"), nil];
    [_context start];

    XCTAssertTrue(_topThingFactory.ready);

    id value = _topThingFactory.instantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqual(@"abc", ((TopThing *)value).aString);
}

-(void) testInitializerWithStringAndScalar {

    AcIgnoreSelectorWarnings(
                             SEL selector = @selector(initWithString:andInt:);
                             )
    [_context objectFactory:_topThingFactory
                initializer:selector, AcString(@"abc"), AcInt(5), nil];
    [_context start];

    XCTAssertTrue(_topThingFactory.ready);

    id value = _topThingFactory.instantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
    XCTAssertEqual(@"abc", ((TopThing *)value).aString);
    XCTAssertEqual(5, ((TopThing *)value).aInt);
}

-(void) testInitializerWithArray {
    AcIgnoreSelectorWarnings(
                             SEL selector = @selector(initWithNestedThings:);
                             )
    [_context objectFactory:_topThingFactory
                initializer:selector, AcArgument([NSArray class], AcClass(NestedThing), nil), nil];
    [_context start];
    
}

@end
