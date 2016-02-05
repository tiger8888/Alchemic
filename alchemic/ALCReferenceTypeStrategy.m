//
//  ALCFactoryTypeReference.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCReferenceTypeStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCReferenceTypeStrategy

@synthesize value = _value;

-(id)value {
    if (_value == nil) {
        @throw [NSException exceptionWithName:@"AlchemicReferenceValueNotSet"
                                       reason:[NSString stringWithFormat:@"%@ Builder is marked as a Reference to an external value, but value has not been set.", self]
                                     userInfo:nil];
    }
    return _value;
}

-(bool) resolved {
    return _value != nil;
}

@end

NS_ASSUME_NONNULL_END
