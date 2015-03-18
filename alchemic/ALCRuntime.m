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
#import "ALCInitialisationStrategyInjector.h"
#import "ALCLogger.h"

@implementation ALCRuntime

static const size_t _prefixLength = strlen(toCharPointer(ALCHEMIC_METHOD_PREFIX));

+(void) scanForMacros {
    
    logRuntime(@"Scanning for alchemic methods in runtime");
    
    // Find out how many classes there are in total.
    int numClasses = objc_getClassList(NULL, 0);
    
    // Allocate the memory to contain an array of the classes found.
    Class * classes = (__unsafe_unretained Class *) malloc(sizeof(Class) * (unsigned long) numClasses);
    
    // Don't use the return number from this call because it's often wrong. Reported as a Bug to Apple.
    // Now load the array with the classes.
    numClasses = objc_getClassList(classes, numClasses);
    
    // Now scan them.
    Class nextClass;
    for (int index = 0; index < numClasses; index++) {
        //for (int index = 0; index < nbrClasses; index++) {
        
        nextClass = classes[index];
        
        if (nextClass == NULL) {
            continue;
        }
        
        // Exempt system and known classes.
        if ([ALCRuntime isClassIgnorable:nextClass]) {
            continue;
        }
        
        // Look for injection points in class.
        [ALCRuntime checkClassForRegistrations:nextClass];
        
    }
    
    // Free the array.
    free(classes);
}

+(BOOL) isClassIgnorable:(Class) class {
    // Ignore if the class if it's a know system class.
    const char *className = class_getName(class);
    return
    strncmp(className, "NS", 2) == 0
    || strncmp(className, "UI", 2) == 0
    || strncmp(className, "CF", 2) == 0
    || strncmp(className, "XC", 2) == 0
    || strncmp(className, "OS", 2) == 0
    || strncmp(className, "_", 1) == 0
    || strncmp(className, "Alchemic", 8) == 0;
}

+(void) checkClassForRegistrations:(Class) class {
    
    // Get the class methods.
    unsigned int methodCount;
    Method *classMethods = class_copyMethodList(object_getClass(class), &methodCount);
    
    // Search the methods for registration methods.
    Method currMethod;
    SEL sel;
    for (size_t idx = 0; idx < methodCount; ++idx) {
        
        currMethod = classMethods[idx];
        sel = method_getName(currMethod);
        const char * methodName = sel_getName(sel);
        if (strncmp(methodName, toCharPointer(ALCHEMIC_METHOD_PREFIX), _prefixLength) != 0) {
            continue;
        }
        logRuntime(@"Found alchemic method %s::%s", class_getName(class), methodName);
        ((void (*)(id, SEL))objc_msgSend)(class, sel); // Note cast because of XCode 6
        
    }
    
    free(classMethods);
}

+(Ivar) variableInClass:(Class) class forInjectionPoint:(const char *) inj {
    Ivar var = class_getInstanceVariable(class, inj);
    if (var == NULL) {
        // It may be a property we have been passed so look for a '_' var.
        char * propertyName = NULL;
        asprintf(&propertyName, "%s%s", "_", inj);
        var = class_getInstanceVariable(class, propertyName);
        if (var == NULL) {
            // Still null then it's may be a class variable.
            var = class_getClassVariable(class, inj);
            if (var == NULL) {
                // Ok, throw an error.
                @throw [NSException exceptionWithName:@"AlchemicInjectionNotFound"
                                               reason:[NSString stringWithFormat:@"Cannot find variable/property '%s' in class %s", inj, class_getName(class)]
                                             userInfo:nil];
            }
        }
    }
    return var;
}

+(NSArray *) filterObjects:(NSArray *) objects forProtocols:(NSArray *) protocols {

    logObjectResolving(@"Filtering objects using protocols");

    NSMutableArray *results = [[NSMutableArray alloc] init];
    BOOL conformsToProtocol;
    
    for (id object in objects) {
        
        Class objClass = [object class];
        conformsToProtocol = YES;
        
        for (Protocol *protocol in protocols) {
            if (!class_conformsToProtocol(objClass, protocol)) {
                conformsToProtocol = NO;
                break;
            }
        }
        
        if (conformsToProtocol) {
            [results addObject:object];
        }
        
    }
    return [results count] == 0 ? nil: results;
}

@end
