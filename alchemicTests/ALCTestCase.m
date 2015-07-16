//
//  ALCTestCase.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <StoryTeller/StoryTeller.h>
#import "ALCTestCase.h"
#import "ALCPrimaryObjectDependencyPostProcessor.h"
#import "ALCRuntime.h"
#import "ALCRuntimeScanner.h"

@implementation ALCTestCase {
    id _mockAlchemic;
}

-(void) tearDown {
    // Stop the mocking.
    _mockAlchemic = nil;
    // Reset logging.
    [[STStoryTeller storyTeller] reset];
}

-(void) mockAlchemicContext {
    _context = [[ALCContext alloc] init];
    _mockAlchemic = OCMClassMock([ALCAlchemic class]);
    OCMStub(ClassMethod([_mockAlchemic mainContext])).andReturn(_context);
}

-(void) setUpALCContextWithClasses:(NSArray<Class> __nonnull *) classes {
    NSSet<ALCRuntimeScanner *> *scanners = [NSSet setWithArray:@[
                                                                 //[ALCRuntimeScanner modelScanner],
                                                                 [ALCRuntimeScanner dependencyPostProcessorScanner],
                                                                 [ALCRuntimeScanner objectFactoryScanner],
                                                                 //[ALCRuntimeScanner initStrategyScanner],
                                                                 [ALCRuntimeScanner resourceLocatorScanner]
                                                                 ]];
    [ALCRuntime scanRuntimeWithContext:_context runtimeScanners:scanners];

    ALCRuntimeScanner *modelScanner = [ALCRuntimeScanner modelScanner];
    [classes enumerateObjectsUsingBlock:^(Class  __nonnull aClass, NSUInteger idx, BOOL * __nonnull stop) {
        modelScanner.processor(self.context, aClass);
    }];
    
    [_context start];

}

@end
