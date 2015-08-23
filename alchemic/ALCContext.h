//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@protocol ALCDependencyPostProcessor;
@protocol ALCValueResolver;
@protocol ALCModelSearchExpression;
@class ALCClassBuilder;
@protocol ALCBuilder;
@protocol ALCMacro;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Simple block definition.
 */
typedef void (^AcSimpleBlock) (void);

/**
 *  Name of a notification sent after Alchemic has finished loading all singletons and performed all relevant injections.
 */
extern NSString * const AlchemicFinishedLoading;

/**
 Block used when processing a set of ACLBuilders.
 */
#define ProcessBuiderBlockArgs NSSet<id<ALCBuilder>> *builders
typedef void (^ProcessBuilderBlock)(ProcessBuiderBlockArgs);

/**
 An Alchemic context.

 @discussion Alchemic makes use of an instance of this class to provide the central storage for the class model provided by an ALCModel instance. All incoming requests to regsister classes, injections, methods,e tc and to obtain objects are routed through here.
 */
@interface ALCContext : NSObject

#pragma mark - Configuration

/**
 Adds an dependency post processor.

 @discussion dependency post processors are executed after depedencies have been resolve and before their values are accessed for injection.
 @param postProcessor The ALCDependencyPostProcessor to be used.
 */
-(void) addDependencyPostProcessor:(id<ALCDependencyPostProcessor>) postProcessor;

#pragma mark - Registration

/**
 Sets properties on a ALCClassBuilder.

 @param classBuilder The class builder whose properties are to be set.
 @param ... one or more macros which define the properties.
 */
-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Registers a variable dependency for the classbuilder.

 @discussion Each variable dependency will be injected when the class builder creates an object.

 @param classBuilder	The ALCClassBuilder instance which represents the class which needs the injected variable.
 @param variable		The name of the variable. Can be the external name in the the case of a property or the internal name. Alchemic will locate and used the internal name regardless of which is specified.
 @param ... One or more macros which define where to get the dependency from. If none are specified then the variable is examined and a set of default ALCModelSearchExpression objects generated which sources the value from the model based on the variable's class and protocols.
 */
-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder variableDependency:(NSString *) variable, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Registers an initializer for the current class builder.
 
 @discussion By registering an initializer with this method, Alchemic will now use the initializer specified rather than the default `init` method.
 
 When constructing, the number of arguments in the initializer selector must match the number of `AcArg(...)` macros supplied.

 @param classBuilder The parent class builder for the initializer.
 @param initializer  The initializer to use.
 @param ... Zero or more `AcArg(...)` macros which define the arguments of the initializer and where to source them from. Other macros can also be passed here such as `AcFactory`, `AcPrimary` and `AcWithName(...)`.
 */
-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder initializer:(SEL) initializer, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Registers a method for a class that will create an object. 
 
 @discussion This differs from registerClassBuilder:initializer: in that this doesn't create an instance of the parent class builder. It calls the method on the parent builder object to create an instance of returnType.

 @param classBuilder The parent class builder. This ALCBuilder will be asked for a value, and then the method will be executed on that value.
 @param selector     The selector of the method.
 @param returnType   The type of the object that will be returned from the method.
 @param ... Zero or more `AcArg(...)` macros which define the arguments of the selector and where to source them from. Other macros can also be passed here such as `AcFactory`, `AcPrimary` and `AcWithName(...)`.
 */
-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder selector:(SEL) selector returnType:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Callbacks

/**
 Adds a AcSimpleBlock which is called after Alchemic has finished loading.

 @discussion If Alchemic has not finished it's startup procedure, this block is stored and executed at the end of that procedure. This provides a way for object to know when it is safe to use Alchemic's DI functions.
 
 If Alchemic has finished it's startup when this is called, the block is simple executed immediately.

 @param block The block to call.
 */
-(void) executeWhenStarted:(AcSimpleBlock) block;

#pragma mark - Lifecycle

/**
 Starts the context.

 @discussion After scanning the runtime for Alchemic registrations, this called to start the context. This involves resolving all dependencies, instantiating all registered singletons and finally injecting any dependencies of those singletons.
 */
-(void) start;

#pragma mark - Dependencies

/**
 Access point for objects which need to have dependencies injected.

 @discussion This checks the model against the model. If a class builder is found which matches the class and protocols of the passed object, it is used to inject any listed dependencies into the object.

 @param object the object which needs dependencies injected.
 */
-(void) injectDependencies:(id) object;

#pragma mark - Retrieving

/**
 Searches the model and returns a value matching the requested type.

 @discussion If no ALCModelSearchExpression objects are passed then the returnType is used to generate a list of class and protocol search expressions and they are used to search the model.

 @param returnType The type of object desired.
 @param ... zero or more ALCModelSearchExpression objects which define where to get the values from.

 @return A value that matches the returnType.
 */
-(id) getValueWithClass:(Class) returnType, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Programmatically invokes a specific method.

 @discussion The method can be a normal instance method registered with AcMethod(...) or an initializer registered with AcInitializer(...). Usually you would use this method rather than an injected value when you need to pass values to the method or initializer which are not available from Alchemic's model or a constant value. In other words, values which are computed just prior to requesting the object from Alchemic.

 Note that this method can be used to invoke multiple methods or initializers. In this case it is assumed that each one takes the same arguments in the same order and an array of result objects will be returned.

 @param methodLocator A model search macro which is used to locate the method or initializer to call.
 @param ...  zero or more macros. If model search macros are passed they are added to the method locator. If AcArg(...) macros then they are assumed to be used to find argument values for the method to be invoked.

 @return either an object or an array of objects if multiple builders are found.
 */
-(id) invokeMethodBuilders:(id<ALCModelSearchExpression>) methodLocator, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Working with builders

/**
 Adds a ALCBuilder to the model.

 @param builder The builder to add.
 */
-(void) addBuilderToModel:(id<ALCBuilder>) builder;

/**
 Uses a set of ALCModelSearchExpression objects to find a set of builders in the model, the executes a block on each one.
 
 @discussion This is mainly used for processing builders to filter them for a final set.

 @param searchExpressions    A NSSet of ALCModelSearchExpression objects which define the search criteria for finding the builders.
 @param processBuildersBlock A block which is called, passing each builder in turn.
 */
-(void) executeOnBuildersWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions
                       processingBuildersBlock:(ProcessBuilderBlock) processBuildersBlock;

@end

NS_ASSUME_NONNULL_END
