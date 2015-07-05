//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCMethodBuilder.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import <Alchemic/ALCContext.h>

@implementation ALCMethodBuilder {
    ALCClassBuilder *_parentClassBuilder;
    SEL _selector;
    NSInvocation *_inv;
    NSMutableArray<ALCDependency *> *_invArgumentDependencies;
    BOOL _useClassMethod;
}

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                                   name:(NSString __nonnull *)name
                     parentClassBuilder:(ALCClassBuilder __nonnull *) parentClassBuilder
                               selector:(SEL __nonnull) selector
                             qualifiers:(NSArray __nonnull *) qualifiers {

    self = [super initWithContext:context valueClass:valueClass name:@"X"];
    if (self) {

        Class parentClass = parentClassBuilder.valueClass;
        [ALCRuntime validateSelector:selector withClass:parentClass];

        // Locate the method.
        Method method = class_getInstanceMethod(parentClass, selector);
        if (method == NULL) {
            _useClassMethod = YES;
            method = class_getClassMethod(parentClass, selector);
        }

        // Validate the number of arguments.
        unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
        if (nbrArgs != [qualifiers count]) {
            @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
                                           reason:[NSString stringWithFormat:@"%s::%s - Expecting %lu argument matchers, got %lu",
                                                   class_getName(parentClass),
                                                   sel_getName(selector),
                                                   nbrArgs,
                                                   (unsigned long)[qualifiers count]]
                                         userInfo:nil];
        }

        _parentClassBuilder = parentClassBuilder;
        _selector = selector;
        _invArgumentDependencies = [[NSMutableArray alloc] init];

        // Setup the dependencies for each argument.
        Class arrayClass = [NSArray class];
        [qualifiers enumerateObjectsUsingBlock:^(id qualifier, NSUInteger idx, BOOL *stop) {
            NSSet<ALCQualifier *> *qualifierSet = [qualifier isKindOfClass:arrayClass] ? [NSSet setWithArray:qualifier] : [NSSet setWithObject:qualifier];
            [self->_invArgumentDependencies addObject:[[ALCDependency alloc] initWithContext:context
                                                                                  valueClass:[NSObject class]
                                                                                  qualifiers:qualifierSet]];
        }];

    }
    return self;
}

-(id) value {
    id returnValue = super.value;
    if (returnValue == nil) {
        returnValue = [self instantiate];
        ALCContext *strongContext = self.context;
        [strongContext injectDependencies:returnValue];
    }
    return returnValue;
}

-(id) resolveValue {

    STLog([self description], @"Creating object with %@", [self description]);

    id factoryObject = _factoryClassBuilder.value;

    // Get an invocation ready.
    if (_factoryInvocation == nil) {
        NSMethodSignature *sig = [factoryObject methodSignatureForSelector:_factorySelector];
        _factoryInvocation = [NSInvocation invocationWithMethodSignature:sig];
        _factoryInvocation.selector = _factorySelector;
        [_factoryInvocation retainArguments];
    }

    // Load the arguments.
    [self.dependencies enumerateObjectsUsingBlock:^(ALCDependency *dependency, NSUInteger idx, BOOL *stop) {
        id argument = dependency.value;
        [self->_factoryInvocation setArgument:&argument atIndex:(NSInteger)idx];
    }];

    [_factoryInvocation invokeWithTarget:factoryObject];

    id returnObj;
    [_factoryInvocation getReturnValue:&returnObj];
    STLog([self description], @"   Method created a %s", class_getName([returnObj class]));
    return returnObj;

}

-(NSString *) description {
    return [NSString stringWithFormat:@"Method builder -(%1$s) %1$s::%2$s", class_getName(_factoryClassBuilder.valueClass), sel_getName(_factorySelector)];
}

@end
