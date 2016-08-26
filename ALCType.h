//
//  ALCValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

/**
 Enum of types for comparing when mapping.
 */
typedef NS_ENUM(NSUInteger, ALCValueType) {
    ALCValueTypeUnknown,
    ALCValueTypeBool,
    ALCValueTypeChar,
    ALCValueTypeCharPointer,
    ALCValueTypeDouble,
    ALCValueTypeFloat,
    ALCValueTypeInt,
    ALCValueTypeLong,
    ALCValueTypeLongLong,
    ALCValueTypeShort,
    ALCValueTypeUnsignedChar,
    ALCValueTypeUnsignedInt,
    ALCValueTypeUnsignedLong,
    ALCValueTypeUnsignedLongLong,
    ALCValueTypeUnsignedShort,
    ALCValueTypeStruct,
    ALCValueTypeObject
};

NS_ASSUME_NONNULL_BEGIN

/**
 Simple class containing information about a type.
 */
@interface ALCValue : ALCValueType

@property (nonatomic, strong) NSValue *value;

/**
 A string containing the type data for scalar types.
 */
@property (nonatomic, assign, readonly) ALCValueType type;

@property (nonatomic, strong, readonly) NSString *typeDescription;

@property (nonatomic, strong, readonly) NSString *methodNamePart;

/**
 The name of a struct. ie. CGRect, CGSize, etc.
 */
@property (nonatomic, assign, nullable, readonly) const char *scalarType;

/**
 The class if the type is an object type.
 */
@property (nonatomic, assign, nullable, readonly) Class objcClass;

/**
 Any protocols that the class implements.
 */
@property (nonatomic, strong, nullable, readonly) NSArray<Protocol *> *objcProtocols;

/**
 Returns an instance of ALCValue containing information about the type of the ivar.
 
 @param iVar The ivar to examine.
 
 @return An instance of ALCValue containing the type information.
 */
+(ALCValue *) valueForIvar:(Ivar) ivar;

/**
 Factory method for analysing a passed encoding.
 
 @param encoding The encoding to analyse.
 */
+(instancetype) valueWithEncoding:(const char *) encoding;

/**
 Factory method for analysing a passed encoding.
 
 @param encoding The encoding to analyse.
 */
+(instancetype) value:(nullable NSValue *) value withEncoding:(const char *) encoding;

-(instancetype) init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
