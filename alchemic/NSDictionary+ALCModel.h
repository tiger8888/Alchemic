//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInstance.h"

@interface NSDictionary (ALCModel)

#pragma mark - Finding instances.

-(ALCInstance *) instanceForObject:(id) object;

-(ALCInstance *) instanceForClass:(Class) class withName:(NSString *) name;

-(NSArray *) instancesWithMatcherArray:(NSArray *) matchers;

#pragma mark - Finding objects

-(NSArray *) objectsWithMatchers:(id) firstMatcher, ...;

-(NSArray *) objectsWithMatcherArray:(NSArray *) matchers;

#pragma mark - Adding new instances

-(void) addInstance:(ALCInstance *) instance;

-(void) addObject:(id) finalObject withName:(NSString *) name;

@end
