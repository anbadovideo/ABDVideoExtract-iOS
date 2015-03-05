//
//  Video.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 3/5/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject

@property (nonatomic, strong, readonly) NSString *id;
@property (nonatomic, strong, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) NSString *provider;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *thumbnail;
@property (nonatomic, strong, readonly) NSNumber *viewCount;
@property (nonatomic, strong, readonly) NSNumber *duration;

- (instancetype)initFromDictionary:(NSDictionary *)dictionary;

@end
