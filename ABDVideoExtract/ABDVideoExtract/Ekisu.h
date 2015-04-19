//
//  Ekisu.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 3/5/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Ekisu : NSObject
@property (nonatomic, strong, readonly) NSString *ekisuId;
@property (nonatomic, strong, readonly) NSString *video;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *thumbnail;
@property (nonatomic, strong, readonly) NSArray *sections;
@property (nonatomic, strong, readonly) NSNumber *duration;
@property (nonatomic, strong, readonly) NSDate *created;
@property (nonatomic, strong, readonly) NSString *index;
@property (nonatomic, strong, readonly) NSString *shareLink;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSArray *)parseSectionString:(NSString *)sectionString;

@end
