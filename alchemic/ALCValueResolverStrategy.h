//
//  ALCDependencyInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependency;

/**
 Protocol for classes that can resolve the final values from the list of candidates in a dependency object.
 */
@protocol ALCValueResolverStrategy <NSObject>

/**
 Used by the factory to decide if this resolver should be used for a specific dependency.
 */
-(BOOL) canResolveValueForDependency:(ALCDependency *) dependency values:(NSSet<id> *) values;

/**
 Returns an object derived from the value.
 */
-(id) resolveValues:(NSSet<id> *) values;

@end