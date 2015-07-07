//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCQualifier.h>
#import <Alchemic/ALCInternal.h>
#import "ALCRuntime.h"
#import <StoryTeller/StoryTeller.h>

/**
 Block type for checking this qualifier against a builder to see if it applies.

 @param builder	the builder to be checked.

 @return YES if the builder can be matched by the qualifier.
 */
typedef BOOL(^QualifierCheck)(id<ALCBuilder> __nonnull builder);

@interface ALCQualifier ()
-(nonnull instancetype) initWithValue:(id __nonnull) value;
@end

@implementation ALCQualifier {
    QualifierCheck __nonnull _checkBlock;
}

+(nonnull instancetype) qualifierWithValue:(id __nonnull) value {
    return [[ALCQualifier alloc] initWithValue:value];
}

-(nonnull instancetype)initWithValue:(id __nonnull) value {

    self = [super init];
    if (self) {

        _value = value;

        // sort of the check block.
        if ([ALCRuntime objectIsAClass:value]) {
            STLog(value, @"Qualifier [%@]", NSStringFromClass(value));
            _checkBlock = ^BOOL(id<ALCBuilder> builder) {
                return [builder.valueClass isSubclassOfClass:value];
            };

        } else if ([ALCRuntime objectIsAProtocol:value]) {
            STLog(value, @"Qualifier <%@>", NSStringFromProtocol(value));
            _checkBlock = ^BOOL(id<ALCBuilder> builder) {
                return [builder.valueClass conformsToProtocol:value];
            };

        } else {
            STLog(value, @"Qualifier '%@'", value);
            _checkBlock = ^BOOL(id<ALCBuilder> builder) {
                return [builder.name isEqualToString:value];
            };
        }
    }
    return self;
}

-(BOOL) matchesBuilder:(id<ALCBuilder> __nonnull) builder {
    return _checkBlock(builder);
}

-(NSString *) description {
    return [@"Arg: " stringByAppendingString:[_value description]];
}

@end
