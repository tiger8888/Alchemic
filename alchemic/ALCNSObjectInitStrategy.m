//
//  ALCSimpleInitWrapper.m
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCNSObjectInitStrategy.h"

@import UIKit;

#import <objc/runtime.h>
#import <objc/message.h>

#import "ALCLogger.h"
#import "ALCRuntimeFunctions.h"
#import "ALCOriginalInitInfo.h"
#import "ALCContext.h"
#import "Alchemic.h"

@implementation ALCNSObjectInitStrategy

-(BOOL) canWrapInitInClass:(Class) class {
    return ! class_decendsFromClass(class, [UIViewController class]);
}

-(SEL) wrapperSelector {
    return @selector(initWrapper);
}

-(SEL) initSelector {
    return @selector(init);
}

-(id) initWrapper {
    
    // Get the original init's IMP and call it or the default if no IMP has been stored (because there wasn't one).
    ALCOriginalInitInfo *initInfo = [ALCNSObjectInitStrategy initInfoForClass:[self class] initSelector:_cmd];
    
    if (initInfo.initIMP == NULL) {
        struct objc_super superData = {self, class_getSuperclass([self class])};
        self = ((id (*)(struct objc_super *, SEL))objc_msgSendSuper)(&superData, @selector(init));
    } else {
        self = ((id (*)(id, SEL))initInfo.initIMP)(self, initInfo.initSelector);
    }
    
    logRuntime(@"Triggering dependency injection in init");
    [[Alchemic mainContext] resolveDependencies:self];
    
    return self;
}

@end
