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
#import "EkisuSection.h"
#import "ABDEkisuSlider.h"
#import "Ekisu.h"
#import "Video.h"
#import "MBProgressHUD.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface ABDPlayerViewController ()
@property (nonatomic, strong) MBProgressHUD *loadingView;
@property (nonatomic, strong) NSURL *streamURL;
- (void)initSliderTimer;
- (void)syncSlider;

- (void)trackingEvent:(NSString *)action label:(NSString *)label;
@end

@interface ABDPlayerViewController (Player)
- (CMTime)playerItemDuration;
- (void)removePlayerTimeObserver;
- (void)registerPlayerTimeObserver;
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

    [self.view setBackgroundColor:[UIColor clearColor]];

    [self initSliderTimer];
    [self syncSlider];

    // playbackView initializing.
    _playbackView = [[ABDPlaybackView alloc] init];
    _playbackView.frame = self.view.frame;

    _loadingView = [[MBProgressHUD alloc] init];
    _loadingView.color = [UIColor clearColor];
    [self.view addSubview:_loadingView];

    // playerControl initializing.
    ABDPlayerControls *controls = [[ABDPlayerControls alloc] initWithMoviePlayer:self];

    // slider initializing.
    ABDEkisuSlider *slider = [[ABDEkisuSlider alloc] init];
    slider.userInteractionEnabled = NO;
    [slider setEkisuSections:_extractSections];
    [controls setExtractSlider:slider];
    [self setControls:controls];

    _sectionCounter = 0;    // 엑기스 구간 순차 재생을 위한 카운터
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"PlayerViewController";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self removePlayerTimeObserver];
    [self.player pause];
    [self initEkisuSectionChecker];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:self.playerItem];
    [self.playbackView.layer removeFromSuperlayer];
}

- (void)setControls:(ABDPlayerControls *)controls {
    if (_controls != controls) {
        _controls = controls;
        _controls.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:_controls];
    }
}

- (void)setFrame:(CGRect)frame {
    // 플레이어 뷰의 프레임과 동시에 playbackView의 frame도 함께 조정
    self.view.frame = frame;
    self.playbackView.frame = frame;
    [self.controls setNeedsLayout]; // 플레이어 뷰의 frame에 맞게 controls도 위치 재조정.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    self.playbackView.frame = self.view.frame;  // 플레이어 뷰의 frame에 맞게 playbackView도 위치 재조정.
    [self.controls setNeedsLayout]; // 플레이어 뷰의 frame에 맞게 controls도 위치 재조정.
}

- (void)showPlayerView:(BOOL)show {
    // 로딩 전에 기존에 재생 되던 비디오 화면을 숨기기 위한 메서드.
    _playbackView.alpha = show;
    _controls.alpha = show;
}

#pragma mark Set Properties

- (void)setEkisu:(Ekisu *)ekisu {
    _ekisu = ekisu;
    [self setIdentifier:ekisu.video.identifier];
    [self setExtractSections:ekisu.sections];
    [self setExtractDuration:[ekisu.duration floatValue]];
}

- (void)setExtractSections:(NSArray *)extractSections {
    _extractSections = extractSections;
    self.controls.extractSlider.ekisuSections = extractSections;
}

- (void)setDuration:(NSTimeInterval)duration {
    _controls.extractSlider.duration = duration;
}

#pragma mark Asset URL

- (void)setIdentifier:(NSString *)identifier {
    if (identifier == nil || [identifier isEqualToString:@""])
        return;

    [_loadingView show:YES];    // showing loading view.

    _identifier = identifier;
    [[XCDYouTubeClient defaultClient] getVideoWithIdentifier:_identifier completionHandler:^(XCDYouTubeVideo *video, NSError *error) {
        if (video) {
            // set video duration for expression of ekisu-spread.
            [self setDuration:video.duration];

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
    CMTime interval = CMTimeMake(33, 2000); // 60 fps

    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }

    /* Update the scrubber during normal playback. */
    __weak ABDPlayerViewController *weakSelf = self;
    timeObserver = [self.player addPeriodicTimeObserverForInterval:interval
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

#pragma mark - ekisu checking methods

- (void)initEkisuSectionChecker {
    _sectionCounter = 0;
}

- (void)checkExtractSection:(NSTimeInterval)time {
    if (_sectionCounter == -1)
        // if counter is -1, not ekisu play mode. but all play mode.
        return;

    NSTimeInterval currentTimeInterval = time;
    if (_sectionCounter == [_extractSections count]-1 && currentTimeInterval > [_extractSections[_sectionCounter] endTime]) {
        // 마지막 섹션일 때 별도 처리
        [self.player pause];
        [_controls hideEndingView:NO];
    } else if ([_extractSections[_sectionCounter] endTime] < currentTimeInterval && currentTimeInterval < [_extractSections[_sectionCounter+1] startTime]) {
        // remove player time observer.
        [self removePlayerTimeObserver];

        // 이전 섹션의 endTime과 다음 섹션의 startTime 사이일 때 ; 즉, skip해야하는 timeline일 때
        [self.player seekToTime:CMTimeMakeWithSeconds([_extractSections[_sectionCounter+1] startTime], NSEC_PER_SEC)];
        _sectionCounter++;

        // re-register player time observer.
        [self registerPlayerTimeObserver];
    } else {
        // 엑기스 구간 재생 중일 때
        NSTimeInterval remainExtractDuration = _extractDuration;    // 현재 남은 엑기스 재생시간을 위한 변수 선언 및 초기화
        for (int i=0; i<_sectionCounter; i++)
            remainExtractDuration -= [(EkisuSection *)_extractSections[i] duration];  // 현재 재생 중인 엑기스 구간 이전의 엑기스 구간의 duration들을 모두 뺀다.
        [_controls setRemainTime:remainExtractDuration - (currentTimeInterval -[(EkisuSection *)_extractSections[_sectionCounter] startTime])];
        // 해당 엑기스 구간의 재생 시점에서 시작 시간을 뺀 시간(해당 엑기스에서 재생 된 시간)을 앞선 변수에서 뺀 시간(=남은 엑기스 재생 시간)을 설정.
    }
}

- (void)skipForwardEkisuSection:(BOOL)isForward {
    if (isForward) {
        // skip forward.
        if (_sectionCounter < [_ekisu.sections count]-1) {
            _sectionCounter++;
        }
    } else {
        // skip backward.
        if (_sectionCounter > 0) {
            // reduce count of section counter except first section.
            _sectionCounter--;
        }
    }
    [self.player seekToTime:CMTimeMakeWithSeconds([_extractSections[_sectionCounter] startTime], NSEC_PER_SEC)];
}

- (void)replay:(Playmode)mode {
    switch (mode) {
        case PlaymodeEkisu: {
            [self trackingEvent:@"button_press" label:@"ekisu_replay"];

            _sectionCounter = 0;
            [self.player seekToTime:CMTimeMakeWithSeconds([_extractSections[0] startTime], NSEC_PER_SEC)];
            break;
        }
        case PlaymodeAll: {
            [self trackingEvent:@"button_press" label:@"entire_replay"];

            _sectionCounter = -1;
            [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
            break;
        };
    }
    [self.player play];
}

- (BOOL)isPlaying {
    return self.player.rate > 0 && !self.player.error;
}

#pragma mark - Google Analytics Method

- (void)trackingEvent:(NSString *)action label:(NSString *)label {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:self.screenName];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
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

- (void)registerPlayerTimeObserver {
    if (!timeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }

        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CMTime interval = CMTimeMake(33, 2000); // 60 fps
            __weak ABDPlayerViewController *weakSelf = self;
            timeObserver = [self.player addPeriodicTimeObserverForInterval:interval
                                                                     queue:NULL
                                                                usingBlock:^(CMTime time)
                                                                {
                                                                    [weakSelf syncSlider];
                                                                }];
        }
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
                [self showPlayerView:YES];   // 재생 준비되면 보이기.
                [_loadingView hide:YES];

                [_controls hideEndingView:YES];
                [self initSliderTimer];
                [self initEkisuSectionChecker];
                [self.player seekToTime:CMTimeMakeWithSeconds([_extractSections[0] startTime], NSEC_PER_SEC)];
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

            // 영상이 준비 되면 제일 아래 layer에 playback 레이어를 추가한다.
            [self.view.layer insertSublayer:self.playbackView.layer atIndex:0];

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
