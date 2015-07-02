//
//  ALCProtocolMatcher.h
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCMatcher.h>

@interface ALCProtocolMatcher : NSObject<ALCMatcher>

+(instancetype) matcherWithProtocol:(Protocol *) protocol;

@end