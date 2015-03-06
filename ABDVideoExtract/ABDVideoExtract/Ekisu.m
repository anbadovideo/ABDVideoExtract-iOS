//
//  Ekisu.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 3/5/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "Ekisu.h"
#import "Video.h"

@implementation Ekisu

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _id = dictionary[@"id"];
        _video = [[Video alloc] initFromDictionary:dictionary[@"video"]];
        _title = dictionary[@"title"];
        _thumbnail = dictionary[@"thumbnail"];
        _sections = dictionary[@"section"];

        if ([dictionary[@"last_updated"] isKindOfClass:[NSDate class]]) {
            _created = dictionary[@"last_updated"];
        }
    }

    return self;
}

@end
