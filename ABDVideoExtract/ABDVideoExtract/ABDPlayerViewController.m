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
#import "ExtractSection.h"
#import "ABDExtractSlider.h"

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

    if (_extractSections == nil) {
        ExtractSection *section1 = [[ExtractSection alloc] initWithStartTime:32.2f endTime:43.0f];
        ExtractSection *section2 = [[ExtractSection alloc] initWithStartTime:47.3f endTime:70.1f];
        ExtractSection *section3 = [[ExtractSection alloc] initWithStartTime:98.4f endTime:102.0f];
        ExtractSection *section4 = [[ExtractSection alloc] initWithStartTime:110.4f endTime:118.0f];
        ExtractSection *section5 = [[ExtractSection alloc] initWithStartTime:125.4f endTime:129.0f];
        ExtractSection *section6 = [[ExtractSection alloc] initWithStartTime:164.4f endTime:170.0f];
        NSArray *sections = @[section1, section2, section3, section4, section5, section6];
        NSInteger ekisuDuration = 0;
        for (ExtractSection *extractSection in sections) {
            ekisuDuration += [extractSection endTime] - [extractSection startTime];
        }
        NSLog(@"ekisu duration %d", ekisuDuration);
        _extractSections = sections;
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

             ABDPlayerControls *controls = [[ABDPlayerControls alloc] initWithMoviePlayer:self];
            [controls setExtractSections:_extractSections];

            ABDExtractSlider *slider = [[ABDExtractSlider alloc] init];
            [slider setExtractSections:_extractSections];
            [controls setExtractSlider:slider];

            [self setControls:controls];
            _controls = controls;
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

- (void)setControls:(ABDPlayerControls *)controls {
    if (_controls != controls) {
        _controls = controls;
        _controls.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:_controls];
    }
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
