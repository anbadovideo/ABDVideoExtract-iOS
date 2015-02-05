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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initSliderTimer];
    [self syncSlider];

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
            NSDictionary *streamURLs = video.streamURLs;
            // Todo : 나중에 HD 옵션 설정 기능 추가.
            NSURL *URL = streamURLs[@(XCDYouTubeVideoQualityHD720)] ?: streamURLs[@(XCDYouTubeVideoQualityMedium360)] ?: streamURLs[@(XCDYouTubeVideoQualitySmall240)];
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
    timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
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
    }
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
                [self.player play];
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
