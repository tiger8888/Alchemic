//
//  ALCModelValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCModelValueSource.h"
#import "ALCBuilder.h"
#import "ALCAlchemic.h"
#import "ALCContext.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCInternalMacros.h"
#import "NSSet+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Sources values from the model.
 */
@implementation ALCModelValueSource {
    NSSet<id<ALCBuilder>> *_candidateBuilders;
}

-(instancetype) init {
    return nil;
}

-(instancetype) initWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions {
    self = [super init];
    if (self) {
        _searchExpressions = searchExpressions;
        if ([searchExpressions count] == 0) {
            @throw [NSException exceptionWithName:@"AlchemicMissingSearchExpressions"
                                           reason:[NSString stringWithFormat:@"No search expressions passed"]
                                         userInfo:nil];
        }
    }
    return self;
}

-(NSSet<id> *) values {
    NSMutableSet<id> *results = [[NSMutableSet alloc] init];
    [_candidateBuilders enumerateObjectsUsingBlock:^(id<ALCBuilder> builder, BOOL * stop) {
        [results addObject:builder.value];
    }];
    return results;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {

    STLog(self, @"Resolving %@", self);

    [super resolveWithPostProcessors:postProcessors];
    [[ALCAlchemic mainContext] executeOnBuildersWithSearchExpressions:_searchExpressions
                                              processingBuildersBlock:^(ProcessBuiderBlockArgs) {

                                                  NSSet<id<ALCBuilder>> *finalBuilders = builders;
                                                  for (id<ALCDependencyPostProcessor> postProcessor in postProcessors) {
                                                      finalBuilders = [postProcessor process:finalBuilders];
                                                      if ([finalBuilders count] == 0) {
                                                          break;
                                                      }
                                                  }

                                                  STLog(ALCHEMIC_LOG, @"Found %lu candidates", [finalBuilders count]);
                                                  self->_candidateBuilders = finalBuilders;
                                              }];

    // If there are no candidates left then error.
    if ([_candidateBuilders count] == 0) {
        @throw [NSException exceptionWithName:@"AlchemicNoCandidateBuildersFound"
                                       reason:[NSString stringWithFormat:@"Unable to resolve value using %@ - no candidate builders found.", [_searchExpressions componentsJoinedByString:@", "]]
                                     userInfo:nil];
    }
}

-(void)validateWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {
    for (id<ALCBuilder> candidate in _candidateBuilders) {
        [candidate validateWithDependencyStack:dependencyStack];
    }
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Model: %@", [_searchExpressions componentsJoinedByString:@", "]];
}

@end

NS_ASSUME_NONNULL_END