//
//  ABDVideoPlayerControls.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDVideoPlayerControls.h"
#import "ABDExtractSlider.h"
#import "ABDVideoPlayerViewController.h"
#import "ExtractSection.h"

const static int kHeightOfBottomBar = 44;

@interface ABDVideoPlayerControls ()
@property (nonatomic, weak) ABDVideoPlayerViewController *playerViewController;
@property (nonatomic) NSUInteger sectionCounter;

@property (nonatomic, getter = isShowing) BOOL showing;

@property (nonatomic, strong) NSTimer *durationTimer;

@property (nonatomic, strong) UIView *activityBackgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIView *bottomBar;

@end

@implementation ABDVideoPlayerControls

- (id)initWithMoviePlayer:(ABDVideoPlayerViewController *)playerViewController {
    self = [super init];
    if (self) {\
        _playerViewController = playerViewController;

        // 건너 띈 구간 체크를 위한 카운터.
        _sectionCounter = 0;

        [self setup];
        [self addNotifications];
    }
    return self;
}

- (void)setup {
    _bottomBar = [[UIView alloc] init];
    _bottomBar.backgroundColor = [UIColor clearColor];
    [self addSubview:_bottomBar];

}

- (void)setExtractSlider:(ABDExtractSlider *)extractSlider {
    if (_extractSlider != extractSlider) {
        _extractSlider = extractSlider;
        [_bottomBar addSubview:_extractSlider];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect screenBound = [[UIScreen mainScreen] bounds];
    self.bottomBar.frame = CGRectMake(0, screenBound.size.height - kHeightOfBottomBar, screenBound.size.width, kHeightOfBottomBar);
    _extractSlider.frame = CGRectMake(0, 0, _bottomBar.frame.size.width, _bottomBar.frame.size.height);
}

# pragma mark - Notifications

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDurationAvailable:) name:MPMovieDurationAvailableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
}

- (void)movieFinished:(NSNotification *)note {
    [self.durationTimer invalidate];
    [_playerViewController.moviePlayer setCurrentPlaybackTime:0.0];
    [self monitorMoviePlayback]; //reset values
//    [self hideControls:nil];
}

- (void)movieLoadStateDidChange:(NSNotification *)note {
    switch (_playerViewController.moviePlayer.loadState) {
        case MPMovieLoadStatePlayable:
        case MPMovieLoadStatePlaythroughOK:
//            [self showControls:nil];
            break;
        case MPMovieLoadStateStalled:
        case MPMovieLoadStateUnknown:
            break;
        default:
            break;
    }
}

- (void)moviePlaybackStateDidChange:(NSNotification *)note {
    switch (_playerViewController.moviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying:
            [self startDurationTimer];

        case MPMoviePlaybackStateSeekingBackward:
        case MPMoviePlaybackStateSeekingForward:
            break;
        case MPMoviePlaybackStateInterrupted:
            break;
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateStopped:
            [self stopDurationTimer];
            break;
        default:
            break;
    }
}

- (void)movieDurationAvailable:(NSNotification *)note {
    [self setDurationSliderMaxMinValues];
}

# pragma mark - Internal Methods

- (void)startDurationTimer {
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(monitorMoviePlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopDurationTimer {
    [self.durationTimer invalidate];
}

- (void)setDurationSliderMaxMinValues {
    NSTimeInterval duration = _playerViewController.moviePlayer.duration;
    _extractSlider.minimumValue = 0.f;
    _extractSlider.maximumValue = (float)duration;
}

- (void)monitorMoviePlayback {
    double currentTime = floor(_playerViewController.moviePlayer.currentPlaybackTime);
    double totalTime = floor(_playerViewController.moviePlayer.duration);
//    [self setTimeLabelValues:currentTime totalTime:totalTime];
    _extractSlider.value = (float)(currentTime);

    [self checkSection];
}

#pragma mark - monitoring extract sections

- (void)checkSection {
    NSTimeInterval timeInterval = _playerViewController.moviePlayer.currentPlaybackTime;
    if (_sectionCounter == [_extractSections count]-1 && timeInterval > [_extractSections[_sectionCounter] endTime]) {
        // 마지막 섹션일 때 별도 처리
        [_playerViewController.moviePlayer pause];
    } else if ([_extractSections[_sectionCounter] endTime] < timeInterval && timeInterval < [_extractSections[_sectionCounter+1] startTime]) {
        [UIView animateWithDuration:0.5f animations:^{
            // 이전 섹션의 endTime과 다음 섹션의 startTime 사이일 때 ; 즉, skip해야하는 timeline일 때
            _playerViewController.moviePlayer.currentPlaybackTime = [_extractSections[_sectionCounter+1] startTime];
            _sectionCounter++;
        } completion:^(BOOL finished) {
        }];
    }
}
@end
