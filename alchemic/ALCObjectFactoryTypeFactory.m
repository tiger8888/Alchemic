//
//  ALCFactoryTypeFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCObjectFactoryTypeFactory.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeFactory

@synthesize object = _object;

-(bool) ready {
    return YES;
}

-(void) setObject:(id) value {}

@end

NS_ASSUME_NONNULL_END

