//
//  ALCNameMatcher.h
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCMatcher.h"

@interface ALCNameMatcher : NSObject<ALCMatcher>

-(instancetype) initWithName:(NSString *) name;

@end
