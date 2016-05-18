//
//  ALCClassObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCClassObjectFactory.h"
#import "ALCVariableDependency.h"
#import "ALCRuntime.h"
#import "NSObject+Alchemic.h"
#import "ALCInternalMacros.h"
#import "ALCDependency.h"
#import "ALCClassObjectFactoryInitializer.h"
#import "AlchemicAware.h"
#import "Alchemic.h"
#import "ALCInstantiation.h"
#import "ALCVariableDependency.h"

@implementation ALCClassObjectFactory {
    NSMutableArray<id<ALCDependency>> *_dependencies;
    BOOL _resolved;
    BOOL _checkingReadyStatus;
}

@synthesize initializer = _initializer;

#pragma mark - Life cycle

-(instancetype) initWithClass:(Class) objectClass {
    self = [super initWithClass:objectClass];
    if (self) {
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) registerInjection:(id<ALCInjector>) injection forVariable:(Ivar) variable withName:(NSString *) variableName {
    ALCVariableDependency *ref = [ALCVariableDependency variableDependencyWithInjection:injection
                                                                               intoIvar:variable
                                                                                   name:variableName];
    [_dependencies addObject:ref];
}

-(void)resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {
    STLog(self.objectClass, @"Resolving class factory %@", NSStringFromClass(self.objectClass));
    blockSelf;
    [self resolveFactoryWithResolvingStack:resolvingStack
                              resolvedFlag:&_resolved
                                     block:^{
                                         
                                         [strongSelf->_initializer resolveWithStack:resolvingStack model:model];
                                         
                                         STLog(strongSelf.objectClass, @"Resolving %i injections into a %@", strongSelf->_dependencies.count, NSStringFromClass(strongSelf.objectClass));
                                         for (ALCVariableDependency *ref in strongSelf->_dependencies) {
                                             [resolvingStack addObject:ref];
                                             [ref.injection resolveWithStack:resolvingStack model:model];
                                             [resolvingStack removeLastObject];
                                         }
                                     }];
}

-(BOOL) ready {
    if (super.ready && (!_initializer || _initializer.ready)) {
        return [self dependenciesReady:_dependencies checkingStatusFlag:&_checkingReadyStatus];
    }
    return NO;
}

-(id) createObject {
    if (_initializer) {
        return _initializer.createObject;
    }
    STLog(self.objectClass, @"Instantiating a %@ using init", NSStringFromClass(self.objectClass));
    return [[self.objectClass alloc] init];
}

-(ALCObjectCompletion) objectCompletion {
    blockSelf;
    return ^(ALCObjectCompletionArgs){
        if (strongSelf->_initializer) {
            ALCObjectCompletion completion = strongSelf->_initializer.objectCompletion;
            if (completion) {
                completion(object);
            }
        }
        [ALCRuntime executeSimpleBlock:[strongSelf injectDependenciesIntoObject:object]];
    };
}

#pragma mark - Tasks

-(ALCSimpleBlock) injectDependenciesIntoObject:(id) object {
    
    STLog(self.objectClass, @"Injecting dependencies into a %@", NSStringFromClass(self.objectClass));
    
    NSMutableArray<ALCSimpleBlock> *completions = [[NSMutableArray alloc] init];
    for (ALCVariableDependency *dep in _dependencies) {
        [ALCRuntime executeSimpleBlock:[dep injectObject:object]];
    }
    
    return [completions combineSimpleBlocks];
}

#pragma mark - Descriptions

-(NSString *) description {
    return str(@"%@ class %@", super.description, self.defaultModelKey);
}

-(NSString *)resolvingDescription {
    return str(@"Class %@", NSStringFromClass(self.objectClass));
}

@end
