//
//  AlchemicRuntime.m
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "ALCRuntime.h"
#import "ALCInternal.h"
#import "ALCInstance.h"
#import "ALCLogger.h"
#import "ALCDependency.h"
#import "NSDictionary+ALCModel.h"

@implementation ALCRuntime

static Class protocolClass;

+(void) initialize {
    protocolClass = objc_getClass("Protocol");
}

#pragma mark - General

+(BOOL) class:(Class) child extends:(Class) parent {
    Class nextParent = child;
    while(nextParent) {
        if (nextParent == parent) {
            return YES;
        }
        nextParent = class_getSuperclass(nextParent);
    }
    return NO;
}

+(BOOL) classIsProtocol:(Class) possiblePrototocol {
    return protocolClass == possiblePrototocol;
}

+(Ivar) class:(Class) class withName:(NSString *) name {
    const char * charName = [name UTF8String];
    Ivar var = class_getInstanceVariable(class, charName);
    if (var == NULL) {
        // It may be a class variable.
        var = class_getClassVariable(class, charName);
        if (var == NULL) {
            // It may be a property we have been passed so look for a '_' var.
            var = class_getInstanceVariable(class, [[@"_" stringByAppendingString:name] UTF8String]);
        }
    }
    return var;
}

+(void) validateMatcher:(id) object {
    if ([object conformsToProtocol:@protocol(ALCMatcher)]) {
        return;
    }
    @throw [NSException exceptionWithName:@"AlchemicUnableNotAMatcher"
                                   reason:[NSString stringWithFormat:@"Passed matcher %s does not conform to the ALCMatcher protocol", object_getClassName(object)]
                                 userInfo:nil];
}

#pragma mark - Alchemic

static const size_t _prefixLength = strlen(_alchemic_toCharPointer(ALCHEMIC_PREFIX));

#pragma mark - Class scanning

+(void) findAlchemicClasses:(void (^)(ALCInstance *)) registerClassBlock {

    // Find out how many classes there are in total.
    int numClasses = objc_getClassList(NULL, 0);
    
    // Allocate the memory to contain an array of the classes found.
    Class * classes = (__unsafe_unretained Class *) malloc(sizeof(Class) * (unsigned long) numClasses);
    
    // Now load the array with the classes.
    numClasses = objc_getClassList(classes, numClasses);
    
    // Now scan them.
    Class nextClass;
    NSArray *bundles = [NSBundle allBundles];
    for (int index = 0; index < numClasses; index++) {
        nextClass = classes[index];
        const char *className = class_getName(nextClass);
        if (strncmp(className, "ALC", 3) == 0
            || strncmp(className, "Alc", 3) == 0
            || ! [bundles containsObject:[NSBundle bundleForClass:nextClass]]
            ) {
            continue;
        }
        ALCInstance *instance = [self executeAlchemicMethodsInClass:nextClass];
        if (instance != nil) {
            registerClassBlock(instance);
        }
    }
    return;
    
    
    for (NSBundle *bundle in [NSBundle allBundles]) {

        logRuntime(@"Scanning bundle %@", bundle);
        unsigned int count = 0;
        const char** classes = objc_copyClassNamesForImage([[bundle executablePath] UTF8String], &count);
        
        for(unsigned int i = 0;i < count;i++){

            if (strncmp(classes[i], "ALC", 3) == 0 || strncmp(classes[i], "Alc", 3) == 0) {
                continue;
            }
            
            Class class = objc_getClass(classes[i]);
            ALCInstance *instance = [self executeAlchemicMethodsInClass:class];
            if (instance != nil) {
                registerClassBlock(instance);
            }
        }
    }
}

+(ALCInstance *) executeAlchemicMethodsInClass:(Class) class {
    
    // Get the class methods. We need to get the class of the class for them.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(class), &methodCount);
    
    // Search the methods for registration methods.
    ALCInstance *instance = nil;
    for (size_t idx = 0; idx < methodCount; ++idx) {
        
        SEL sel = method_getName(classMethods[idx]);
        const char * methodName = sel_getName(sel);
        if (strncmp(methodName, _alchemic_toCharPointer(ALCHEMIC_PREFIX), _prefixLength) != 0) {
            continue;
        }
        
        if (instance == nil) {
            instance = [[ALCInstance alloc] initWithClass:class];
        }
        
        logRuntime(@"Executing %s::%s ...", class_getName(class), methodName);
        ((void (*)(id, SEL, ALCInstance *))objc_msgSend)(class, sel, instance); // Note cast because of XCode 6
        
    }
    
    free(classMethods);
    return instance;
}

#pragma mark - Alchemic

+(Ivar) class:(Class) class variableForInjectionPoint:(NSString *) inj {
    
    const char * charName = [inj UTF8String];
    Ivar var = class_getInstanceVariable(class, charName);
    if (var == NULL) {
        // It may be a class variable.
        var = class_getClassVariable(class, charName);
        if (var == NULL) {
            // It may be a property we have been passed so look for a '_' var.
            var = class_getInstanceVariable(class, [[@"_" stringByAppendingString:inj] UTF8String]);
        }
    }
    
    if (var == NULL) {
        @throw [NSException exceptionWithName:@"AlchemicInjectionNotFound"
                                       reason:[NSString stringWithFormat:@"Cannot find variable/property '%@' in class %s", inj, class_getName(class)]
                                     userInfo:nil];
    }
    
    logRegistration(@"Inject: %@, mapped to variable: %s", inj, ivar_getName(var));
    return var;
}

@end
