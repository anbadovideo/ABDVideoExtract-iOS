//
//  Video.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 3/5/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "Video.h"

@implementation Video
- (instancetype)initFromDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _videoId = [dictionary[@"id"] stringValue];
        _identifier = dictionary[@"identifier"];
        _provider = dictionary[@"provider"];
        _title = dictionary[@"title"];
        _thumbnail = dictionary[@"thumbnail"];
        _viewCount = dictionary[@"view_count"];
        _duration = dictionary[@"duration"];
    }
    return self;
}


@end
