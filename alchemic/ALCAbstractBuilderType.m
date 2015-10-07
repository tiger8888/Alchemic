//
//  ALCAbstractALCBuilderType.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilderType.h"

#import "ALCMacroProcessor.h"

#import "ALCBuilderStorageSingleton.h"
#import "ALCBuilderStorageFactory.h"
#import "ALCBuilderStorageExternal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractBuilderType

@synthesize builder = _builder;

-(NSString *) builderName {
    methodNotImplementedObject;
}

-(NSUInteger)macroProcessorFlags {
    methodNotImplementedInt;
}

-(void) configureWithMacroProcessor:(ALCMacroProcessor *) macroProcessor {
    if (self.builder == nil) {
        @throw [NSException exceptionWithName:@"AlchemicBuilderNotSet"
                                       reason:@"Builder strategies must have the builder property set."
                                     userInfo:nil];
    }
}

-(void)willResolve {}

-(ALCBuilderType)type{
    methodNotImplementedInt;
}

-(id) instantiateObject {
    methodNotImplementedObject;
}

-(void)injectDependencies:(id) object {
    methodNotImplementedVoid;
}

-(NSString *)attributeText {
    methodNotImplementedObject;
}

-(BOOL)canInjectDependencies {
    methodNotImplementedBoolean;
}

-(void)addVariableInjection:(Ivar) variable valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory {
    methodNotImplementedVoid;
}

-(id)invokeWithArgs:(NSArray<id> *)arguments {
    methodNotImplementedObject;
}

@end

NS_ASSUME_NONNULL_END