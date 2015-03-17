//
//  ExtractSection.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "EkisuSection.h"

@implementation EkisuSection
+ (EkisuSection *)extractSectionWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    EkisuSection *extractSection = [[EkisuSection alloc] initWithStartTime:startTime endTime:endTime];
    return extractSection;
}

- (instancetype)initWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    self = [super init];
    if (!self) {
        return nil;
    }
    _startTime = startTime;
    _endTime = endTime;
    return self;
}

- (NSTimeInterval)duration {
    if (self.endTime - self.startTime < 0)
        return 0;
    return self.endTime - self.startTime;
}

@end
