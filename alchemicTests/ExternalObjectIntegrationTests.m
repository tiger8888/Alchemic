//
//  ExternalObjectIntegrationTests.m
//  alchemic
//
//  Created by Derek Clarkson on 1/10/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

@interface EOObject : NSObject
@end

@implementation EOObject
AcRegister()
@end

@interface ExternalObjectIntegrationTests : ALCTestCase
@end

@implementation ExternalObjectIntegrationTests {
    EOObject *_obj;
}

AcRegister(AcExternal)
AcInject(_obj)

-(void) setUp {
    STStartLogging(@"LogAll");
    [self setupRealContext];
    [self startContextWithClasses:@[[EOObject class], [ExternalObjectIntegrationTests class]]];
}

-(void) testNotInstantiated {
    XCTAssertNil(_obj);
    AcInjectDependencies(self);
    XCTAssertNotNil(_obj);
}

-(void) testInsertingObjectIntoModel {
    EOObject *o2 = [[EOObject alloc] init];
    XCTAssertNil(_obj);
    AcSet(o2, AcClass(EOObject));
    AcInjectDependencies(self);
    XCTAssertNotNil(_obj);
    XCTAssertEqual(o2, _obj);
}

@end