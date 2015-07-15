//
//  ALCModelValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCModelValueSource.h"
#import <OCMock/OCMock.h>
#import <Alchemic/ALCContext.h>
#import <Alchemic/ALCQualifier.h>
#import "ALCDependencyPostProcessor.h"
#import "ALCContext+Internal.h"
#import "ALCInternalMacros.h"
#import <StoryTeller/StoryTeller.h>

@interface ALCModelValueSourceTests : XCTestCase

@end

@implementation ALCModelValueSourceTests

-(void) testResolveWithPostProcessors {
    STStartLogging(ALCHEMIC_LOG);
    id mockBuilder = OCMProtocolMock(@protocol(ALCBuilder));
    NSSet<id<ALCBuilder>> *builders = [NSSet setWithObject:mockBuilder];

    id mockContext = OCMClassMock([ALCContext class]);
    ALCQualifier *qualifier = [ALCQualifier qualifierWithValue:@"abc"];
    NSSet<ALCQualifier *> *qualifiers = [NSSet setWithObject:qualifier];

    id mockPostProcessor = OCMProtocolMock(@protocol(ALCDependencyPostProcessor));
    NSSet<id<ALCDependencyPostProcessor>> *postProcessors = [NSSet setWithObject:mockPostProcessor];

    OCMExpect([mockContext executeOnBuildersWithQualifiers:qualifiers
                                   processingBuildersBlock:OCMOCK_ANY]).andDo(^(NSInvocation *inv){
        __unsafe_unretained ProcessBuilderBlock block = NULL;
        [inv getArgument:&block atIndex:3];
        block(builders);
    });
    OCMExpect([mockPostProcessor process:builders]).andReturn(builders);

    ALCModelValueSource *source = [[ALCModelValueSource alloc] initWithContext:mockContext qualifiers:qualifiers];
    [source resolveWithPostProcessors:postProcessors];

}


@end
