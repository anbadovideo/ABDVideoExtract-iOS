//
//  Utility.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/16/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "Utility.h"

@implementation Utility
+ (NSString *)secondsToMMSS:(double)seconds {
    // transfer min-seconds to H:MM:SS
    NSInteger time = (NSInteger) floor(seconds);
    NSInteger mm = time / 60;
    NSInteger ss = time % 60;
    if (mm >= 100)
        return [NSString stringWithFormat:@"%03i:%02i", mm, ss];
    else
        return [NSString stringWithFormat:@"%02i:%02i", mm, ss];
}

+ (NSTimeInterval)mmssToSeconds:(NSString *)mmss {
    NSArray *strings = [mmss componentsSeparatedByString:@":"];
    NSTimeInterval seconds = [strings[0] doubleValue] * 60 + [strings[1] doubleValue];
    return seconds;
}


@end
