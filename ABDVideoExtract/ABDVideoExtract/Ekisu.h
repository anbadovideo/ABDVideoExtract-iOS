//
//  Ekisu.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 3/5/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video;

@interface Ekisu : NSObject
@property (nonatomic, strong, readonly) NSNumber *id;
@property (nonatomic, strong, readonly) Video *video;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *thumbnail;
@property (nonatomic, strong, readonly) NSArray *sections;
@property (nonatomic, strong, readonly) NSDate *created;

@end
