//
//  ALCFactoryMethod.h
//  alchemic
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractModelObject.h"

@class ALCInstance;

@interface ALCFactoryMethod : ALCAbstractModelObject

@property (nonatomic, strong) NSArray *argumentMatchers;

-(instancetype) initWithContext:(__weak ALCContext *) context
                factoryInstance:(ALCInstance *) factoryInstance
                factorySelector:(SEL) factorySelector
                     returnType:(Class) returnTypeClass
               argumentMatchers:(NSArray *) argumentMatchers;

@end
