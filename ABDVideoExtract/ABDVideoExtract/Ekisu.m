//
//  Ekisu.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 3/5/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "Ekisu.h"
#import "Video.h"
#import "ExtractSection.h"
#import "Utility.h"

@implementation Ekisu

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _ekisuId = [dictionary[@"id"] stringValue];
        _video = [[Video alloc] initFromDictionary:dictionary[@"video"]];
        _title = dictionary[@"title"];
        _thumbnail = dictionary[@"thumbnail"];
        _sections = [self parseSectionString:dictionary[@"section"]];
        _duration = dictionary[@"duration"];

        if ([dictionary[@"created"] isKindOfClass:[NSDate class]]) {
            _created = dictionary[@"created"];
        } else {
            NSDateFormatter *dateFormatter = [Utility dateFormatter];
            NSString *lastUpdatedString = dictionary[@"created"];
            _created = [dateFormatter dateFromString:lastUpdatedString];
        }
    }
    return self;
}

- (NSArray *)parseSectionString:(NSString *)sectionString {
    NSMutableArray *sections = [NSMutableArray new];
    NSArray *separatedStrings = [sectionString componentsSeparatedByString:@", "];
    for (NSString *aSectionString in separatedStrings) {
        NSArray *ekisuTimes = [aSectionString componentsSeparatedByString:@":"];
        ExtractSection *extractSection = [ExtractSection extractSectionWithStartTime:[ekisuTimes[0] floatValue] endTime:[ekisuTimes[1] floatValue]];
        [sections addObject:extractSection];
    }
    return sections;
}

@end
