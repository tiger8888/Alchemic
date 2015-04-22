//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <objc/runtime.h>

#import "Alchemic.h"
#import "ALCContext.h"
#import "ALCLogger.h"
#import "ALCInternal.h"

#import "ALCRuntime.h"

#import "AlchemicAware.h"

#import "ALCInstance.h"

#import "ALCNameMatcher.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"

#import "ALCDependency.h"

#import "ALCSimpleDependencyInjector.h"
#import "ALCArrayDependencyInjector.h"

#import "ALCObjectFactory.h"
#import "ALCSimpleObjectFactory.h"

#import "ALCPlistResourceLocator.h"
#import "ALCBundleResourceLocator.h"
#import "ALCFileContentsResourceLocator.h"

#import "NSDictionary+ALCModel.h"

@implementation ALCContext {
    NSMutableArray *_dependencyInjectors;
    NSMutableArray *_objectFactories;
    NSDictionary *_model;
}

#pragma mark - Lifecycle

-(instancetype) init {
    self = [super init];
    if (self) {
        
        logConfig(@"Initing context");
        
        // Create storage for objects.
        _model = [[NSMutableDictionary alloc] init];
        
        _objectFactories = [[NSMutableArray alloc] init];
        [self addObjectFactory:[[ALCSimpleObjectFactory alloc] initWithContext:self]];
        
        _dependencyInjectors = [[NSMutableArray alloc] init];
        [self addDependencyInjector:[[ALCSimpleDependencyInjector alloc] init]];
        [self addDependencyInjector:[[ALCArrayDependencyInjector alloc] init]];
        
        // Add value resolvers as objects in the model.
        [_model addObject:[[ALCPlistResourceLocator alloc] init] withName:nil];
        [_model addObject:[[ALCBundleResourceLocator alloc] init] withName:nil];
        [_model addObject:[[ALCFileContentsResourceLocator alloc] init] withName:nil];
        
    }
    return self;
}

-(void) start {
    logRuntime(@"Starting alchemic");
    [self resolveDependencies];
    [self instantiateObjects];
    [self injectDependencies];
}

-(void) instantiateObjects {
    logCreation(@"Instantiating objects ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *instance, BOOL *stop) {
        [instance instantiateUsingFactories:_objectFactories];
    }];
}

-(void) injectDependencies {
    logRuntime(@"Injecting dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *instance, BOOL *stop) {
        [instance injectDependenciesUsingInjectors:_dependencyInjectors];
    }];
}

-(void) injectDependencies:(id) object {
    
    logRuntime(@"Injecting dependencies into a %s", object_getClassName(object));
    
    // Object will have a matching instance in the model if it has any injection point.
    ALCInstance *instance = [_model instanceForObject:object];
    
    if (instance == nil) {
        logConfig(@"No instance found for an instance of %s", object_getClassName(object));
        return;
    }

    // Store any current object.
    id finalObject = instance.finalObject;

    // Set the final object and inject it.
    instance.finalObject = object;
    [instance injectDependenciesUsingInjectors:_dependencyInjectors];

    // Restore the final object.
    instance.finalObject = finalObject;
    
}

-(void) resolveDependencies {
    logDependencyResolving(@"Resolving dependencies ...");
    [_model enumerateKeysAndObjectsUsingBlock:^(NSString *name, ALCInstance *instance, BOOL *stop){
        logDependencyResolving(@"Resolving dependencies in '%@' (%s)", name, class_getName(instance.forClass));
        [instance resolveDependenciesWithModel:_model];
    }];
}

#pragma mark - Configuration

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory {
    logConfig(@"Adding object factory: %s", object_getClassName(objectFactory));
    [_objectFactories insertObject:objectFactory atIndex:0];
}

-(void) addDependencyInjector:(id<ALCDependencyInjector>) dependencyinjector {
    logConfig(@"Adding dependency injector: %s", object_getClassName(dependencyinjector));
    [_dependencyInjectors insertObject:dependencyinjector atIndex:0];
}

-(void) addInstance:(ALCInstance *) instance {
    [_model addInstance:instance];
}

@end
