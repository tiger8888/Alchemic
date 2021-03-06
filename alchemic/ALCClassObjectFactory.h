//
//  ALCClassObjectFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <Alchemic/ALCAbstractObjectFactory.h>

@protocol ALCInjector;
@protocol ALCValueSource;
@class ALCClassObjectFactoryInitializer;
@class ALCVariableDependency;
@class ALCType;

/**
 Object factory that can instantiate classes. Can also optionally take a ALCClassObjectFactoryInitializer to define the initializer to use when instantiating an instance.
 */
@interface ALCClassObjectFactory : ALCAbstractObjectFactory

/**
 The ALCClassObjectFactoryInitializer to use when creating objects. If nil, then the default init is used.
 */
@property (nonatomic, strong) ALCClassObjectFactoryInitializer *initializer;

/**
 Adds a variable injection to the factory.
 
 After instantiating an instance using this factory, the completion block will perform all the injections registered via this method.
 
 @param variable     The variable to inject.
 @param variableName The original name of the varibable as specified during registration.
 
 @return The new variable injection object.
 */
-(ALCVariableDependency *) registerVariableDependency:(Ivar) variable
                                                 type:(ALCType *) type
                                          valueSource:(id<ALCValueSource>) valueSource
                                             withName:(NSString *) variableName;

/**
 Injects values into the passed object.
 
 @param object The object to be injected.
 */
-(void) injectDependencies:(id) object;

@end
