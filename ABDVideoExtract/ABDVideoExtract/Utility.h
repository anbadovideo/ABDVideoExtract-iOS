//
//  Utility.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/16/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <math.h>

@interface Utility : NSObject

+ (NSString *)secondsToMMSS:(double)seconds;
+ (NSTimeInterval)mmssToSeconds:(NSString *)mmss;
@end
