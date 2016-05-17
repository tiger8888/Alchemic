//
//  ALCMethodObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "Alchemic.h"
#import "NSArray+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodObjectFactory {
    ALCClassObjectFactory *_parentObjectFactory;
    NSArray<id<ALCDependency>> *_arguments;
    SEL _selector;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

-(instancetype) initWithClass:(Class)objectClass {
    return nil;
}

-(instancetype) initWithClass:(Class)objectClass
          parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                     selector:(SEL) selector
                         args:(nullable NSArray<id<ALCDependency>> *) arguments {
    self = [super initWithClass:objectClass];
    if (self) {
        [ALCRuntime validateClass:parentObjectFactory.objectClass selector:selector arguments:arguments];
        _parentObjectFactory = parentObjectFactory;
        _selector = selector;
        _arguments = arguments;
    }
    return self;
}

-(NSString *) defaultModelKey {
    return [ALCRuntime selectorDescription:_parentObjectFactory.objectClass selector:_selector];
}

-(void) resolveDependenciesWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack model:(id<ALCModel>) model {
    blockSelf;
    [self resolveFactoryWithResolvingStack:resolvingStack
                              resolvedFlag:&_resolved
                                     block:^{
                                         [strongSelf->_parentObjectFactory resolveWithStack:resolvingStack model:model];
                                         [strongSelf->_arguments resolveArgumentsWithStack:resolvingStack model:model];
                                     }];
}

-(BOOL) ready {
    if (super.ready && _parentObjectFactory.ready) {
        return [self dependenciesReady:_arguments checkingStatusFlag:&_checkingReadyStatus];
    }
    return NO;
}

-(id) createObject {
    STStartScope(self.objectClass);
    ALCInstantiation *parentGeneration = _parentObjectFactory.instantiation;
    [parentGeneration complete];
    return [parentGeneration.object invokeSelector:_selector arguments:_arguments];
}

-(ALCObjectCompletion) objectCompletion {
    return ^(ALCObjectCompletionArgs){
        [[Alchemic mainContext] injectDependencies:object];
    };
}

#pragma mark - Descriptions

-(NSString *) description {
    return str(@"%@ method %@", super.description, self.defaultModelKey);
}

-(NSString *)resolvingDescription {
    return str(@"Method %@", self.defaultModelKey);
}

@end

NS_ASSUME_NONNULL_END
