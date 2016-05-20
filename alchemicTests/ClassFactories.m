//
//  SingletonTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <StoryTeller/StoryTeller.h>

@import Alchemic;

#import "TopThing.h"
#import "NestedThing.h"

@interface ClassFactories : XCTestCase
@end

@implementation ClassFactories {
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

-(void) testSimpleInstantiation {

    [_context start];

    XCTAssertTrue(_topThingFactory.ready);

    id value = _topThingFactory.instantiation.object;
    XCTAssertTrue([value isKindOfClass:[TopThing class]]);
}

-(void) testFactoryCreatingNewInstances {
    [_topThingFactory configureWithOptions:@[[ALCIsFactory factoryMacro]] customOptionHandler:^(id option) {
        XCTFail();
    }];

    [_context start];

    TopThing *t1 = [_context objectWithClass:[TopThing class], nil];
    TopThing *t2 = [_context objectWithClass:[TopThing class], nil];

    XCTAssertNotNil(t1);
    XCTAssertNotNil(t2);
    XCTAssertNotEqual(t1, t2);
}

-(void) testFactoryCreatingNestedNewInstances {
    [_topThingFactory configureWithOptions:@[[ALCIsFactory factoryMacro]] customOptionHandler:^(id option) {
        XCTFail();
    }];
    [_nestedThingFactory configureWithOptions:@[[ALCIsFactory factoryMacro]] customOptionHandler:^(id option) {
        XCTFail();
    }];

    [_context objectFactory:_topThingFactory registerVariableInjection:@"aNestedThing", nil];

    [_context start];

    TopThing *t1 = [_context objectWithClass:[TopThing class], nil];
    TopThing *t2 = [_context objectWithClass:[TopThing class], nil];

    NestedThing *n1 = t1.aNestedThing;
    NestedThing *n2 = t2.aNestedThing;

    XCTAssertNotNil(t1);
    XCTAssertNotNil(t2);
    XCTAssertNotEqual(t1, t2);

    XCTAssertNotNil(n1);
    XCTAssertNotNil(n2);
    XCTAssertNotEqual(n1, n2);
}


@end
