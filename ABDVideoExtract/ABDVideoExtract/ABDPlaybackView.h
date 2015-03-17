//
//  ABDPlayerbackView.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/2/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;

@interface ABDPlaybackView : UIView

@property (nonatomic, strong) AVPlayer* player;

- (void)setPlayer:(AVPlayer*)player;
- (void)setVideoFillMode:(NSString *)fillMode;

@end
