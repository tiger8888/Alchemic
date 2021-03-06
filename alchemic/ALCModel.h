//
//  ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCModelSearchCriteria;
@class ALCClassObjectFactory;
@protocol ALCObjectFactory;
@protocol ALCResolvable;
@protocol ALCContext;
@protocol ALCResolveAspect;

NS_ASSUME_NONNULL_BEGIN

/**
 The main Alchemic model used for storing information about object factories.
 */
@protocol ALCModel <NSObject>

#pragma mark - Finding factories
/// @name Retrieving

/**
 A list of all ALCObjectFactory instances in the model.
 */
@property (nonatomic, readonly, strong) NSArray<id<ALCObjectFactory>> *objectFactories;

/**
 A list of all ALCClassobjectFactory instances in the model.
 */
@property (nonatomic, readonly, strong) NSArray<ALCClassObjectFactory *> *classObjectFactories;

/**
 Returns the matching ALCClassObjectFactory which matches a passed criteria.
 
 @return The matching object factory.
 @throws AN exception if too many factories are found.
 */
-(nullable ALCClassObjectFactory *) classObjectFactoryMatchingCriteria:(ALCModelSearchCriteria *) criteria;

/**
 Searches the model and returns a list of match ALCObjectFactory instances.

 @param criteria The ALCModelSearchCriteria that defines what to return.

 @return A NSArray of factories that match the search criteria.
 */
-(NSArray<id<ALCObjectFactory>> *) objectFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria;

/**
 Returns a list of object factories meeting a criteria.

 The returned object factories will only be ones that can have their objects set. Currently these are either singleton or reference factories.

 @param criteria The search criteria.

 @return A list of object factories.
 */
-(NSArray<id<ALCObjectFactory>> *) settableObjectFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria;

#pragma mark - Setting up the model
/// @name Modifying

/**
 Adds a ALCObjectFactory to the model.
 
 @param objectFactory The factory to add.
 @param name          The name to add the model under. This must be unique. If nil, the factory is queried for it's defaultModelName property which is then used instead.
 */
-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory withName:(nullable NSString *) name;

/**
 Changes the name that an ALCObjectFactory is stored under.
 
 @param oldName       The old name of the object factory.
 @param newName       The new name it will be stored under.
 */
-(void) reindexObjectFactoryOldName:(NSString *) oldName newName:(NSString *) newName;

#pragma mark - Lifecycle
/// @name Lifecycle

-(void) addResolveAspect:(id<ALCResolveAspect>) resolveAspect;

/**
 Resolve all object factories and dependencies.
 
 Each object that needs to be resolved will have all of it's dependencies looked up and references stored so that when it's time to instantiate an object, it already knows where to find the data it needs.
 */
-(void) resolveDependencies;

/**
 Called atfter resolving, this loops through the object factories and automatically instantiates any singleton objects it can find.
 */
-(void) startSingletons;

@end

NS_ASSUME_NONNULL_END
