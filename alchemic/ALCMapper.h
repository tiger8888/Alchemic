//
//  ALCMapper.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCTypeData;

#import <Alchemic/ALCTypeDefs.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALCMapper : NSObject

-(nullable ALCMapBlock) mapFromType:(ALCTypeData *) fromType toType:(ALCTypeData *) toType;

@end

NS_ASSUME_NONNULL_END
