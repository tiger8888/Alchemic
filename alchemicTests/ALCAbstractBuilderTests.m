//
//  ALCObjectBuilderTests.m
//  alchemic
//
//  Created by Derek Clarkson on 26/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCTestCase.h"
#import <OCMock/OCMock.h>
#import <Alchemic/Alchemic.h>

#import "ALCAbstractBuilder.h"
#import "ALCClassBuilder.h"

#import "ALCInstantiator.h"

#import "ALCSingletonStorage.h"
#import "ALCFactoryStorage.h"
#import "ALCExternalStorage.h"

#import "SimpleObject.h"
#import "ALCMacroProcessor.h"

@interface ALCAbstractBuilderTests : ALCTestCase
@end

@implementation ALCAbstractBuilderTests {
    ALCAbstractBuilder *_builder;
}

-(void)setUp {
    _builder = [self simpleBuilderForClass:[SimpleObject class]];
}

#pragma mark - Configure

-(void) testConfigureDefaultSingletonStorage {
    [_builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCAbstractBuilder class], "_valueStorage");
    id storage = object_getIvar(_builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCSingletonStorage class]]);
}

-(void) testConfigureFactoryStorage {
    [_builder.macroProcessor addMacro:AcFactory];
    [_builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCAbstractBuilder class], "_valueStorage");
    id storage = object_getIvar(_builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCFactoryStorage class]]);
}

-(void) testConfigureExternalStorage {
    [_builder.macroProcessor addMacro:AcExternal];
    [_builder configure];
    Ivar storageVar = class_getInstanceVariable([ALCAbstractBuilder class], "_valueStorage");
    id storage = object_getIvar(_builder, storageVar);
    XCTAssertTrue([storage isKindOfClass:[ALCExternalStorage class]]);
}

-(void) testConfigureDefaultName {
    [_builder configure];
    XCTAssertEqualObjects(@"SimpleObject", _builder.name);
}

-(void) testConfigureWithNameSetsNewName {
    [_builder.macroProcessor addMacro:AcWithName(@"abc")];
    [_builder configure];
    XCTAssertEqualObjects(@"abc", _builder.name);
}


#pragma mark - Resolving

-(void) testResolveDefault {
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];
    [_builder resolveWithPostProcessors:postProcessors dependencyStack:stack]; // Doesn't throw.
}

-(void) testResolveWhenCircularDependency {
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray arrayWithObject:_builder];
    XCTAssertThrowsSpecificNamed([_builder resolveWithPostProcessors:postProcessors dependencyStack:stack], NSException, @"AlchemicCircularDependency");
}

#pragma mark - Value

-(void) testValue {
    [_builder configure];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];

    [_builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    SimpleObject *so = _builder.value;
    XCTAssertNotNil(so);
}

-(void) testValueCachesValue {
    [_builder configure];
    NSSet *postProcessors = [NSSet set];
    NSMutableArray *stack = [NSMutableArray array];

    [_builder resolveWithPostProcessors:postProcessors dependencyStack:stack];

    SimpleObject *so1 = _builder.value;
    SimpleObject *so2 = _builder.value;
    XCTAssertEqual(so1, so2);
}

-(void) testValueThrowsWhenNotReady {
    [_builder configure];
    XCTAssertThrowsSpecificNamed(_builder.value, NSException, @"AlchemicBuilderNotAvailable");
}


-(void) testSetValue {
    [self configureAndResolveBuilder:_builder];
    _builder.value = @"abc";
    XCTAssertEqualObjects(@"abc", _builder.value);
}

#pragma mark - Description

-(void) testDescriptionForClass {
    [self configureAndResolveBuilder:_builder];
    XCTAssertEqualObjects(@"* builder for type SimpleObject, name 'SimpleObject', singleton, class builder", [_builder description]);
}

-(void) testDescriptionForClassWhenInstantiated {
    [self configureAndResolveBuilder:_builder];
    [_builder value];
    XCTAssertEqualObjects(@"* builder for type SimpleObject, name 'SimpleObject', singleton, class builder", [_builder description]);

}

-(void) testDescriptionForClassFactory {
    [_builder.macroProcessor addMacro:AcFactory];
    [self configureAndResolveBuilder:_builder];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject', factory, class builder", [_builder description]);
}

-(void) testDescriptionForClassExternal {
    [_builder.macroProcessor addMacro:AcExternal];
    [_builder configure];
    XCTAssertEqualObjects(@"  builder for type SimpleObject, name 'SimpleObject', external, class builder", [_builder description]);
}

@end
