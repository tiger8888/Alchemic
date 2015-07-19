//
//  ALCWithProtocol.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCProtocol.h"

#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCInternalMacros.h>
#import "ALCRuntime.h"
#import <StoryTeller/StoryTeller.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCProtocol

+(instancetype) withProtocol:(Protocol *) aProtocol {
    ALCProtocol *withProtocol = [[ALCProtocol alloc] init];
    withProtocol->_aProtocol = aProtocol;
    return withProtocol;
}

-(int) priority {
    return -1;
}

-(id) cacheId {
    return _aProtocol;
}

-(BOOL) matches:(id<ALCBuilder>) builder {
    return [builder.valueClass conformsToProtocol:_aProtocol];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"With <%s>", protocol_getName(_aProtocol)];
}

#pragma mark - Equality

-(NSUInteger)hash {
    return [[self description] hash];
}

-(BOOL) isEqual:(id)object {
    return self == object
    || ([object isKindOfClass:[ALCProtocol class]] && [self isEqualToWithProtocol:object]);
}

-(BOOL) isEqualToWithProtocol:(nonnull ALCProtocol *)withProtocol {
    return withProtocol != nil && withProtocol.aProtocol == _aProtocol;
}

@end

NS_ASSUME_NONNULL_END