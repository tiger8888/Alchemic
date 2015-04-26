//
//  ALCUIViewControllerInitialisationStrategy.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import UIKit;

#import "ALCUIViewControllerInitWithFrameStrategy.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import "ALCLogger.h"
#import "Alchemic.h"
#import "ALCRuntime.h"
#import "ALCContext.h"

@implementation ALCUIViewControllerInitWithFrameStrategy

-(BOOL) canWrapInitInClass:(Class) class {
    return [ALCRuntime class:class extends:[UIViewController class]];
}

-(SEL) initWrapperSelector {
    return @selector(initWithFrameWrapper:);
}

-(SEL) initSelector {
    return @selector(initWithFrame:);
}

-(id) initWithFrameWrapper:(CGRect) aFrame {
    
    Class selfClass = object_getClass(self);
    SEL initSel = @selector(init);
    SEL relocatedInitSel = [ALCRuntime alchemicSelectorForSelector:initSel];
    
    // If the method exists then call it, otherwise call super.
    if ([self respondsToSelector:relocatedInitSel]) {
        self = ((id (*)(id, SEL, CGRect))objc_msgSend)(self, relocatedInitSel, aFrame);
    } else {
        struct objc_super superData = {self, class_getSuperclass(selfClass)};
        self = ((id (*)(struct objc_super *, SEL, CGRect))objc_msgSendSuper)(&superData, initSel, aFrame);
    }
    
    logRuntime(@"Triggering dependency injection from %s::%s", class_getName(selfClass), sel_getName(initSel));
    [[Alchemic mainContext] injectDependencies:self];

    return self;
}

@end
