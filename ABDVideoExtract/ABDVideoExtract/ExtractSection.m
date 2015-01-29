//
//  ExtractSection.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ExtractSection.h"

@implementation ExtractSection
- (instancetype)initWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    self = [super init];
    if (!self) {
        return nil;
    }
    _startTime = startTime;
    _endTime = endTime;
    return self;
}
@end
