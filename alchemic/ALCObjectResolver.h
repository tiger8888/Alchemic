//
//  ALCDependencyInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependencyResolver;

/**
 Protocol for classes that can resolve the final values from the list of candidates in a dependency object.
 */
@protocol ALCObjectResolver <NSObject>

/**
 Used by the factory to decide if this resolver should be used for a specific dependency.
 */
-(BOOL) canResolveClass:(Class) class;

/**
 Returns an object derived from the candidates object resolvers.
 */
-(id) resolveDependency:(ALCDependencyResolver *) dependency;

/**
 Called during resolution to validate the candidates.
 */
-(void) validateDependencyCandidates:(ALCDependencyResolver *) dependency;

@end
