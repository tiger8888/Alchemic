//
//  ALCVariableDependencyTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
@import XCTest;
@import ObjectiveC;
#import <OCmock/OCMock.h>

#import "ALCVariableDependency.h"
#import "ALCValueSource.h"
#import "SimpleObject.h"
#import "ALCConstantValueSource.h"

@interface ALCVariableDependencyTests : XCTestCase

@end

@implementation ALCVariableDependencyTests {
	ALCVariableDependency *_dependency;
}

-(void) setUp {
	ALCConstantValueSource *valueSource = [[ALCConstantValueSource alloc] initWithType:[NSString class] value:@"abc"];
    [valueSource resolve];
	Ivar var = class_getInstanceVariable([SimpleObject class], "_aStringProperty");
	_dependency = [[ALCVariableDependency alloc] initWithVariable:var valueSource:valueSource];
}

-(void) testInjectsVariable {
	SimpleObject *object = [[SimpleObject alloc] init];
	[_dependency injectInto:object];
	XCTAssertEqualObjects(@"abc", object.aStringProperty);
}

-(void) testDescription {
	XCTAssertEqualObjects(@"_aStringProperty = Constant: abc - instantiable", [_dependency description]);
}

@end
