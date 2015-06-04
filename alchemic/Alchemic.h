//
//  alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInternal.h"
#import "ALCClassBuilder.h"
#import "ALCContext.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCNameMatcher.h"
#import "ALCLogger.h"
@import ObjectiveC;

// Matcher wrapping macros passed to the inject macro.

#define intoVariable(_variableName) _alchemic_toNSString(_variableName)

#define withClass(_className) [ALCClassMatcher matcherWithClass:[_className class]]

#define withProtocol(_protocolName) [ALCProtocolMatcher matcherWithProtocol:@protocol(_protocolName)]

#define withName(_objectName) [ALCNameMatcher matcherWithName:_objectName]

#pragma mark - Injection

#define injectDependencies(object) [[Alchemic mainContext] injectDependencies:object]

#define primary

#pragma mark - Injecting values

// Injects resources which are located via resource locators.
#define localisedValue(key)
#define fileContentsValue(filename)
#define imageValue(imageName, resolution)
#define plistValue(plistName, keyPath)

#pragma mark - Registering

// All registration methods must make use of the same signature.

// Registers an injection point in the current class.
#define inject(_variable, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerDependencyInInstance):(ALCClassBuilder *) classBuilder { \
    [classBuilder addInjectionPoint:_variable, ## __VA_ARGS__, nil]; \
}

/**
 This macros is used to register a class in Alchemic. Registered classes will be created automatically.
 */
#define registerSingleton \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassWithInstance):(ALCClassBuilder *) classBuilder { \
    [[Alchemic mainContext] registerAsSingleton:classBuilder]; \
}

#define registerSingletonWithName(_componentName) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerClassWithInstance):(ALCClassBuilder *) classBuilder { \
    [[Alchemic mainContext] registerAsSingleton:classBuilder withName:_componentName]; \
}

/**
 Adds a pre-built object to the model.
 */
#define registerObjectWithName(_object, _objectName) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerObjectWithInstance):(ALCClassBuilder *) classBuilder { \
    [[Alchemic mainContext] registerObject:_object withName:_objectName]; \
}

/**
 This macros is used to specify that this class is a factory for other objects.
 @param factorySelector the signature of the factory selector.
 @param returnType the Class of the return type. Will be used to for resolving dependecies which will use this factory.
 @param ... a args list of criteria which will be used to locate the arguments needed for the factory method. Argments can be several things.
 A single Matcher object.
 An Array of Matcher objects.
 The number of objects passed must match the number of expected arguments.
 */
#define registerFactoryMethod(_returnTypeClassName, _factorySelector, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerFactoryMethodWithInstance):(ALCClassBuilder *) classBuilder { \
    [[Alchemic mainContext] registerFactory:classBuilder \
                            factorySelector:@selector(_factorySelector) \
                                 returnType:[_returnTypeClassName class], ## __VA_ARGS__, nil]; \
}

#define registerFactoryMethodWithName(_componentName, _returnTypeClassName, _factorySelector, ...) \
+(void) _alchemic_concat(ALCHEMIC_METHOD_PREFIX, _registerFactoryMethodWithInstance):(ALCClassBuilder *) classBuilder { \
    [[Alchemic mainContext] registerFactory:classBuilder \
                                   withName:_componentName \
                            factorySelector:@selector(_factorySelector) \
                                 returnType:[_returnTypeClassName class], ## __VA_ARGS__, nil]; \
}

#pragma mark - The context itself

@interface Alchemic : NSObject

/**
 Returns the main context.
 
 @return An instance of ALCContext.
 */
+(ALCContext *) mainContext;

@end
