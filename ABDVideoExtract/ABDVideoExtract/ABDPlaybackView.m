//
//  ABDPlayerbackView.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/2/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDPlaybackView.h"
#import <AVFoundation/AVFoundation.h>

@implementation ABDPlaybackView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player
{
    return [(AVPlayerLayer*)[self layer] player];
}

- (void)setPlayer:(AVPlayer*)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}

/* Specifies how the video is displayed within a player layer’s bounds.
	(AVLayerVideoGravityResizeAspect is default) */
- (void)setVideoFillMode:(NSString *)fillMode
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer*)[self layer];
    playerLayer.videoGravity = fillMode;
}

@end
