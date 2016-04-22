//
//  ALCAbstractObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"

@class ALCInstantiation;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractObjectFactory : NSObject<ALCObjectFactory>

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithClass:(Class) objectClass NS_DESIGNATED_INITIALIZER;

-(void) configureWithOptions:(NSArray *) options;

-(void) setObject:(id) object;

-(ALCInstantiation *) createObject;

-(void) objectFinished:(id) object;

@end

NS_ASSUME_NONNULL_END