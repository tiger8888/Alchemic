
@import StoryTeller;
@import UIKit;

#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCContextImpl.h>
#import <Alchemic/ALCRuntime.h>

NS_ASSUME_NONNULL_BEGIN

@implementation Alchemic

static __strong id<ALCContext> __mainContext;

+(id<ALCContext>) mainContext {
    return __mainContext;
}

+(void) initialize {
    // Decide whether to start.
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    if ([processInfo.arguments containsObject:@"--alchemic-nostart"]) {
        return;
    }
    [self initContext];
}

+(void) initContext {
    __mainContext = [[ALCContextImpl alloc] init];
}

+(void) load {
    // Normally this will trigger the context instantiation.
    if ([self mainContext]) {
        
        
        
        // Initiate on a background q.
        dispatch_async(dispatch_queue_create("au.com.derekclarkson.Alchemic", DISPATCH_QUEUE_CONCURRENT), ^{
            @autoreleasepool {
                
                // Because we are on a background thread, we need to allow for other threads to make calls before we are ready.
                // So start listening for startup done so that afterwards we can execute any code that has come in before alchemic is loaded.
                [[NSNotificationCenter defaultCenter] addObserverForName:AlchemicDidFinishStarting
                                                                  object:nil
                                                                   queue:nil
                                                              usingBlock:^(NSNotification * _Nonnull note) {
                                                              }];
                
                // Now start alchemic.
                [ALCRuntime scanRuntimeWithContext:__mainContext];
                [__mainContext start];
            }
        });
    }
}

@end

NS_ASSUME_NONNULL_END


