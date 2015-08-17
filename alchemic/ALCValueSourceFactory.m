//
//  ACArg.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCValueSourceFactory.h"
#import "ALCInternalMacros.h"
#import "ALCModelValueSource.h"
#import "ALCConstantValueSource.h"
#import "ALCConstantValue.h"
#import "ALCName.h"
#import "ALCClass.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValueSourceFactory {
    Class _valueType;
}

-(instancetype) init NS_UNAVAILABLE {
    return nil;
}

-(instancetype) initWithType:(Class)valueType {
    self = [super init];
    if (self) {
        _valueType = valueType;
        _macros = [[NSMutableSet alloc] init];
    }
    return self;
}

-(nonnull id<ALCValueSource>) valueSource {
    id macro =_macros.anyObject;
    if ([macro isKindOfClass:[ALCConstantValue class]]) {
        return [[ALCConstantValueSource alloc] initWithType:_valueType value:((ALCConstantValue *)macro).value];
    }
    return [[ALCModelValueSource alloc] initWithType:_valueType searchExpressions:(NSSet<id<ALCModelSearchExpression>> *)_macros];
}

-(void) addMacro:(id<ALCMacro>) macro {

    [(NSMutableSet *)_macros addObject:macro];

    // If any argument is a constant then it must be the only one.
    BOOL classMacroPresent = NO;
    for (id<ALCMacro> nextMacro in _macros) {

        // Constants must be unique.
        if ([nextMacro isKindOfClass:[ALCConstantValue class]] && [_macros count] > 1) {
            @throw [NSException exceptionWithName:@"AlchemicInvalidMacroCombination"
                                           reason:@"If specified, the AcValue(...) must be the only macro."
                                         userInfo:nil];
        }

        // Names must be unique.
        if ([nextMacro isKindOfClass:[ALCName class]] && [_macros count] > 1) {
            @throw [NSException exceptionWithName:@"AlchemicInvalidMacroCombination"
                                           reason:@"If specified, the AcName(...) must be the only macro."
                                         userInfo:nil];
        }

        // Only one class can exist.
        if ([nextMacro isKindOfClass:[ALCClass class]]) {
            if (classMacroPresent) {
                @throw [NSException exceptionWithName:@"AlchemicInvalidMacroCombination"
                                               reason:@"There can only be one AcClass(...) macro."
                                             userInfo:nil];
            } else {
                classMacroPresent = YES;
            }
        }
    }
}

@end

NS_ASSUME_NONNULL_END
