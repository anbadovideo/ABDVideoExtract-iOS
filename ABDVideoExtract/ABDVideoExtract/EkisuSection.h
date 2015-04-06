//
//  ExtractSection.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EkisuSection : NSObject
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;

+ (EkisuSection *)extractSectionWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;

- (instancetype)initWithStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime;
- (NSTimeInterval)duration;
@end