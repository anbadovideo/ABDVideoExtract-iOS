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

@interface ABDPlayerViewController ()
@property (nonatomic, strong) NSURL *streamURL;
- (void)initSliderTimer;
- (void)syncSlider;
@end

@interface ABDPlayerViewController (Player)
- (CMTime)playerItemDuration;
- (void)removePlayerTimeObserver;
@end

static void *ABDPlayerViewControllerRateObservationContext = &ABDPlayerViewControllerRateObservationContext;
static void *ABDPlayerViewControllerStatusObservationContext = &ABDPlayerViewControllerStatusObservationContext;
static void *ABDPlayerViewControllerCurrentItemObservationContext = &ABDPlayerViewControllerCurrentItemObservationContext;

@implementation ABDPlayerViewController
- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _playmode = PlaymodeEkisu;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:[UIColor blackColor]];

    [self initSliderTimer];
    [self syncSlider];

    _sectionCounter = 0;

    if (_identifier == nil) {
        // example video.
        _identifier = [NSString stringWithFormat:@"MrdhHJnQEpw"];
    }

    if (_extractSections == nil) {
        /* 1초씩 잘라서 58초 이내로 편집 ; 42초 */
        ExtractSection *section0 = [[ExtractSection alloc] initWithStartTime:14.0f endTime:15.0f];
        ExtractSection *section1 = [[ExtractSection alloc] initWithStartTime:21.5f endTime:22.5f];
        ExtractSection *section2 = [[ExtractSection alloc] initWithStartTime:23.5f endTime:24.5f];
        ExtractSection *section3 = [[ExtractSection alloc] initWithStartTime:48.0f endTime:49.0f];
        ExtractSection *section4 = [[ExtractSection alloc] initWithStartTime:54.0f endTime:55.0f];
        ExtractSection *section5 = [[ExtractSection alloc] initWithStartTime:56.0f endTime:57.0f];
        ExtractSection *section6 = [[ExtractSection alloc] initWithStartTime:60.3f endTime:61.3f];
        ExtractSection *section7 = [[ExtractSection alloc] initWithStartTime:66.0f endTime:67.0f];
        ExtractSection *section8 = [[ExtractSection alloc] initWithStartTime:70.0f endTime:71.0f];
        ExtractSection *section9 = [[ExtractSection alloc] initWithStartTime:74.0f endTime:75.0f];
        ExtractSection *section10 = [[ExtractSection alloc] initWithStartTime:94.0f endTime:95.0f];
        ExtractSection *section11 = [[ExtractSection alloc] initWithStartTime:108.0f endTime:109.0f];
        ExtractSection *section12 = [[ExtractSection alloc] initWithStartTime:115.0f endTime:116.0f];
        ExtractSection *section13 = [[ExtractSection alloc] initWithStartTime:117.0f endTime:118.0f];
        ExtractSection *section14 = [[ExtractSection alloc] initWithStartTime:126.0f endTime:127.0f];
        ExtractSection *section15 = [[ExtractSection alloc] initWithStartTime:129.0f endTime:130.0f];
        ExtractSection *section16 = [[ExtractSection alloc] initWithStartTime:135.0f endTime:136.0f];
        ExtractSection *section17 = [[ExtractSection alloc] initWithStartTime:147.0f endTime:148.0f];
        ExtractSection *section18 = [[ExtractSection alloc] initWithStartTime:151.0f endTime:152.0f];
        ExtractSection *section19 = [[ExtractSection alloc] initWithStartTime:155.0f endTime:156.0f];
        ExtractSection *section20 = [[ExtractSection alloc] initWithStartTime:158.0f endTime:159.0f];
        ExtractSection *section21 = [[ExtractSection alloc] initWithStartTime:163.0f endTime:164.0f];
        ExtractSection *section22 = [[ExtractSection alloc] initWithStartTime:173.0f endTime:174.0f];
        ExtractSection *section23 = [[ExtractSection alloc] initWithStartTime:174.4f endTime:175.4f];
        ExtractSection *section24 = [[ExtractSection alloc] initWithStartTime:184.0f endTime:185.0f];
        ExtractSection *section25 = [[ExtractSection alloc] initWithStartTime:192.0f endTime:193.0f];
        ExtractSection *section26 = [[ExtractSection alloc] initWithStartTime:195.0f endTime:196.0f];
        ExtractSection *section27 = [[ExtractSection alloc] initWithStartTime:197.0f endTime:198.0f];
        ExtractSection *section28 = [[ExtractSection alloc] initWithStartTime:200.0f endTime:201.0f];
        ExtractSection *section29 = [[ExtractSection alloc] initWithStartTime:203.0f endTime:204.0f];
        ExtractSection *section30 = [[ExtractSection alloc] initWithStartTime:206.0f endTime:207.0f];
        ExtractSection *section31 = [[ExtractSection alloc] initWithStartTime:208.0f endTime:209.0f];
        ExtractSection *section32 = [[ExtractSection alloc] initWithStartTime:210.0f endTime:211.0f];
        ExtractSection *section33 = [[ExtractSection alloc] initWithStartTime:212.5f endTime:213.5f];
        ExtractSection *section34 = [[ExtractSection alloc] initWithStartTime:214.0f endTime:215.0f];
        ExtractSection *section35 = [[ExtractSection alloc] initWithStartTime:217.0f endTime:218.0f];
        ExtractSection *section36 = [[ExtractSection alloc] initWithStartTime:224.8f endTime:225.8f];
        ExtractSection *section37 = [[ExtractSection alloc] initWithStartTime:226.4f endTime:227.4f];
        ExtractSection *section38 = [[ExtractSection alloc] initWithStartTime:228.3f endTime:229.3f];
        ExtractSection *section39 = [[ExtractSection alloc] initWithStartTime:233.0f endTime:234.0f];
        ExtractSection *section40 = [[ExtractSection alloc] initWithStartTime:234.5f endTime:235.5f];

        NSArray *sections = @[section0, section1, section2, section3, section4, section5, section6, section7, section8, section9, section10,
                section11, section12, section13, section14, section15, section16, section17, section18, section19, section20,
                section21, section22, section23, section24, section25, section26, section27, section28, section29, section30,
                section31, section32, section33, section34, section35, section36, section37, section38, section39, section40];

        NSInteger ekisuDuration = 0;
        for (ExtractSection *extractSection in sections) {
            ekisuDuration += [extractSection endTime] - [extractSection startTime];
        }
        NSLog(@"ekisu duration %d", ekisuDuration);
        _extractSections = sections;
    }

    // playbackView initializing.
    _playbackView = [[ABDPlaybackView alloc] init];
    _playbackView.frame = self.view.frame;
    [self.view addSubview:_playbackView];

    // playerControl initializing.
    ABDPlayerControls *controls = [[ABDPlayerControls alloc] initWithMoviePlayer:self];
    [controls setExtractSections:_extractSections];

    // slider initializing.
    ABDExtractSlider *slider = [[ABDExtractSlider alloc] init];
    [slider setExtractSections:_extractSections];
    [controls setExtractSlider:slider];
    [self setControls:controls];

    NSString *videoIdentifier = _identifier; // A 11 characters YouTube video identifier
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:videoIdentifier completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
        if (video) {
            // set video duration for expression of ekisu
            _controls.extractSlider.duration = video.duration;

            NSDictionary *streamURLs = video.streamURLs;
            NSURL *URL = streamURLs[@(XCDYouTubeVideoQualityHD720)] ?: streamURLs[@(XCDYouTubeVideoQualityMedium360)] ?: streamURLs[@(XCDYouTubeVideoQualitySmall240)];
            // Todo : 나중에 HD 옵션 설정 기능 추가.

            // set streaming URL
            [self setURL:URL];
        } else {
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

#pragma mark Asset URL

- (void)setURL:(NSURL*)URL {
    if (_streamURL != URL)
    {
        _streamURL = URL;

        /*
         Create an asset for inspection of a resource referenced by a given URL.
         Load the values for the asset key "playable".
         */
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_streamURL options:nil];

        NSArray *requestedKeys = @[@"playable"];

        /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
                ^{
                    dispatch_async( dispatch_get_main_queue(),
                            ^{
                                /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
                            });
                }];
    }
}

- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys {
    /* Make sure that the value of each key has loaded successfully. */
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
//            [self assetFailedToPrepareForPlayback:error];
            return;
        }
        /* If you are also implementing -[AVAsset cancelLoading], add your code here to bail out properly in the case of cancellation. */
    }

    /* Use the AVAsset playable property to detect whether the asset can be played. */
    if (!asset.playable)
    {
        /* Generate an error describing the failure. */
        NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
        NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDict = [NSDictionary dictionaryWithObjectsAndKeys:
                localizedDescription, NSLocalizedDescriptionKey,
                localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                        nil];
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"StitchedStreamPlayer" code:0 userInfo:errorDict];

        /* Display the error to the user. */
//        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];

        return;
    }

    /* At this point we're ready to set up for playback of the asset. */

    /* Stop observing our prior AVPlayerItem, if we have one. */
    if (self.playerItem)
    {
        /* Remove existing player item key value observers and notifications. */

        [self.playerItem removeObserver:self forKeyPath:@"status"];

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }

    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];

    /* Observe the player item "status" key to determine when it is ready to play. */
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:ABDPlayerViewControllerStatusObservationContext];

    /* When the player item has played to its end time we'll toggle
     the movie controller Pause button to be the Play button */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];

//    seekToZeroBeforePlay = NO;

    /* Create new player, if we don't already have one. */
    if (!self.player)
    {
        /* Get a new AVPlayer initialized to play the specified player item. */
        [self setPlayer:[AVPlayer playerWithPlayerItem:self.playerItem]];

        /* Observe the AVPlayer "currentItem" property to find out when any
         AVPlayer replaceCurrentItemWithPlayerItem: replacement will/did
         occur.*/
        [self.player addObserver:self
                      forKeyPath:@"currentItem"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:ABDPlayerViewControllerCurrentItemObservationContext];

        /* Observe the AVPlayer "rate" property to update the scrubber control. */
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:ABDPlayerViewControllerRateObservationContext];
    }

    /* Make our new AVPlayerItem the AVPlayer's current item. */
    if (self.player.currentItem != self.playerItem)
    {
        /* Replace the player item with a new player item. The item replacement occurs
         asynchronously; observe the currentItem property to find out when the
         replacement will/did occur

		 If needed, configure player item here (example: adding outputs, setting text style rules,
		 selecting media options) before associating it with a player
		 */
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];

//        [self syncPlayPauseButtons];
    }

    [self.controls.extractSlider setValue:0.0];
}

#pragma mark - Movie timeline slider control

-(void)initSliderTimer {
    double interval = .1f;

    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([_controls.extractSlider bounds]);
        interval = 0.5f * duration / width;
    }

    /* Update the scrubber during normal playback. */
    __weak ABDPlayerViewController *weakSelf = self;
    timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_MSEC)
                                                               queue:NULL /* If you pass NULL, the main queue is used. */
                                                          usingBlock:^(CMTime time)
                                                          {
                                                              [weakSelf syncSlider];
                                                          }];
}

/* Set the slider based on the player current time. */
- (void)syncSlider {
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        _controls.extractSlider.minimumValue = 0.0;
        return;
    }

    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        float minValue = [_controls.extractSlider minimumValue];
        float maxValue = [_controls.extractSlider maximumValue];
        double time = CMTimeGetSeconds([self.player currentTime]);

        [_controls.extractSlider setValue:(maxValue - minValue) * time / duration + minValue];

        // for skipping each ekisu sections.
        [self checkExtractSection:time];
    }
}

- (void)checkExtractSection:(NSTimeInterval)time {
    if (_sectionCounter == -1)
        // if counter is -1, not ekisu play mode. but all play mode.
        return;

    NSTimeInterval timeInterval = time;
    if (_sectionCounter == [_extractSections count]-1 && timeInterval > [_extractSections[_sectionCounter] endTime]) {
        // 마지막 섹션일 때 별도 처리
        [self.player pause];
        [_controls hideEndingView:NO];
    } else if ([_extractSections[_sectionCounter] endTime] < timeInterval && timeInterval < [_extractSections[_sectionCounter+1] startTime]) {
        [UIView animateWithDuration:0.5f animations:^{
            // 이전 섹션의 endTime과 다음 섹션의 startTime 사이일 때 ; 즉, skip해야하는 timeline일 때
            [self.player seekToTime:CMTimeMakeWithSeconds([_extractSections[_sectionCounter+1] startTime], NSEC_PER_MSEC)];
            _sectionCounter++;
            NSLog(@"%d", _sectionCounter);
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)replay:(Playmode)mode {
    switch (mode) {
        case PlaymodeEkisu: {
            _sectionCounter = 0;
            [self.player seekToTime:CMTimeMakeWithSeconds([_extractSections[0] startTime], NSEC_PER_MSEC)];
            break;
        }
        case PlaymodeAll: {
            _sectionCounter = -1;
            [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_MSEC)];
            break;
        };
    }
    [self.player play];
}
@end

@implementation ABDPlayerViewController (Player)

#pragma mark Player Item

/* Called when the player item has played to its end time. */
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    /* After the movie has played to its end time, seek back to time zero
        to play it again. */
//    seekToZeroBeforePlay = YES;
    [_controls hideEndingView:NO];
}

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }

    return(kCMTimeInvalid);
}

/* Cancels the previously registered time observer. */
- (void)removePlayerTimeObserver
{
    if (timeObserver)
    {
        [self.player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
}

#pragma mark - Key Value Observing Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    /* AVPlayerItem "status" property value observer. */
    if (context == ABDPlayerViewControllerStatusObservationContext)
    {
//        [self syncPlayPauseButtons];

        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
            /* Indicates that the status of the player is not yet known because
             it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self syncSlider];

//                [self disableScrubber];
//                [self disablePlayerButtons];
            }
                break;

            case AVPlayerItemStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */

                [self initSliderTimer];
                [self.player seekToTime:CMTimeMakeWithSeconds([_extractSections[0] startTime], NSEC_PER_MSEC)];
                [self.player play];
                [self.controls showControls:nil];
//                [self enableScrubber];
//                [self enablePlayerButtons];
            }
                break;

            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
//                [self assetFailedToPrepareForPlayback:playerItem.error];
            }
                break;
        }
    }
        /* AVPlayer "rate" property value observer. */
    else if (context == ABDPlayerViewControllerRateObservationContext)
    {
//        [self syncPlayPauseButtons];
    }
    /* AVPlayer "currentItem" property observer.
        Called when the AVPlayer replaceCurrentItemWithPlayerItem:
        replacement will/did occur. */
    else if (context == ABDPlayerViewControllerCurrentItemObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];

        /* Is the new player item null? */
        if (newPlayerItem == (id)[NSNull null])
        {
//            [self disablePlayerButtons];
//            [self disableScrubber];
        }
        else /* Replacement of player currentItem has occurred */
        {
            /* Set the AVPlayer for which the player layer displays visual output. */
            [self.playbackView setPlayer:self.player];

//            [self setViewDisplayName];

            /* Specifies that the player should preserve the video’s aspect ratio and
             fit the video within the layer’s bounds. */
            [self.playbackView setVideoFillMode:AVLayerVideoGravityResizeAspect];

//            [self syncPlayPauseButtons];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
