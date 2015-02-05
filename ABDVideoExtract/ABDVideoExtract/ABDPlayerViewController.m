//
//  ABDPlayerViewController.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/4/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDPlayerViewController.h"
#import "ABDPlaybackView.h"
#import "ABDPlayerControls.h"
#import "XCDYouTubeVideo.h"
#import "XCDYouTubeClient.h"

@interface ABDPlayerViewController (Player)

@end

@implementation ABDPlayerViewController
- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_identifier == nil) {
        // example video.
        _identifier = [NSString stringWithFormat:@"CCCiKwgGB5I"];
    }

    NSString *videoIdentifier = _identifier; // A 11 characters YouTube video identifier
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoIdentifier completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
        if (video)
        {
            NSDictionary *streamURLs = video.streamURLs;
            // Todo : 나중에 HD 옵션 설정 기능 추가.
            NSURL *URL = streamURLs[@(XCDYouTubeVideoQualityHD720)] ?: streamURLs[@(XCDYouTubeVideoQualityMedium360)] ?: streamURLs[@(XCDYouTubeVideoQualitySmall240)];

            /* create new player, if we don't already have one */
            [self setPlayer:[AVPlayer playerWithURL:URL]];
//            AVPlayerLayer *avPlayerLayer = [[AVPlayerLayer alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:[_player currentItem]];
            [_player addObserver:self forKeyPath:@"status" options:0 context:nil];
//            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
            _playbackView = [[ABDPlaybackView alloc] init];
            [_playbackView setPlayer:_player];
            [_playbackView setVideoFillMode:AVLayerVideoGravityResizeAspect];
            _playbackView.frame = self.view.frame;
            [self.view.layer addSublayer:_playbackView.layer];
        }
        else
        {
            // Handle error
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Key Value Observation Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (object == _player && [keyPath isEqualToString:@"status"]) {
        if (_player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");

        } else if (_player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [_player play];

        } else if (_player.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");

        }
    }
}

@end
