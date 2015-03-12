//
//  ABDPlayerControls.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/4/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDPlayerControls.h"
#import "ABDEkisuSlider.h"
#import "ABDPlayerViewController.h"
#import "Utility.h"

const static int kHeightOfBottomBar = 44;
const static int kWidthOfRemainLabel = 42;
const static int kHeightOfRemainLabel = 21;
const static int kPadding = 10;

@interface ABDPlayerControls ()
@property (nonatomic, weak) ABDPlayerViewController *playerViewController;

@property (nonatomic, getter = isShowing) BOOL showing;

@property (nonatomic, strong) NSTimer *durationTimer;

@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UILabel *remainTimeLabel;

/* Ending view */
@property (nonatomic, strong) UIView *endingView;
@property (nonatomic, strong) UIButton *playAllButton;
@property (nonatomic, strong) UIButton *replayEkisuButton;
@end

@implementation ABDPlayerControls

- (id)initWithMoviePlayer:(ABDPlayerViewController *)playerViewController {
    self = [super init];
    if (self) {
        _playerViewController = playerViewController;
        [self setup];
        [self setupEndingView];
    }
    return self;
}

- (void)setup {
    _bottomBar = [[UIView alloc] init];
    _bottomBar.backgroundColor = [UIColor clearColor];
    [self addSubview:_bottomBar];

    _remainTimeLabel = [[UILabel alloc] init];
    _remainTimeLabel.textColor = [UIColor whiteColor];
    _remainTimeLabel.font = [UIFont boldSystemFontOfSize:11.f];
    _remainTimeLabel.textAlignment = NSTextAlignmentRight;
    [_bottomBar addSubview:_remainTimeLabel];
    [_bottomBar bringSubviewToFront:_remainTimeLabel];
}


- (void)setupEndingView {
    _endingView = [[UIView alloc] initWithFrame:self.frame];
    [_endingView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.7]];

    _playAllButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width / 3 - 100/2, self.frame.size.height * 2 / 5 - 100/2, 100, 100)];
    _playAllButton.layer.cornerRadius = _playAllButton.bounds.size.height / 2;
    _playAllButton.layer.masksToBounds = YES;
    [_playAllButton setBackgroundColor:[UIColor colorWithRed:0.24 green:0.68 blue:0.85 alpha:1.0f]];
    [_playAllButton setTitle:@"Play All" forState:UIControlStateNormal];
    _playAllButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [_playAllButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];

    _replayEkisuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width * 2 / 3 - 100/2, self.frame.size.height * 2 / 5 - 100/2, 100, 100)];
    _replayEkisuButton.layer.cornerRadius = _playAllButton.bounds.size.height / 2;
    _replayEkisuButton.layer.masksToBounds = YES;
    [_replayEkisuButton setBackgroundColor:[UIColor colorWithRed:0.24 green:0.68 blue:0.85 alpha:1.0f]];
    [_replayEkisuButton setTitle:@"Replay Ekisu" forState:UIControlStateNormal];
    _replayEkisuButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [_replayEkisuButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [_endingView addSubview:_playAllButton];
    [_endingView addSubview:_replayEkisuButton];
    [self addSubview:_endingView];
    [_endingView setHidden:YES];
}

- (void)adjustEndingView:(CGRect)frame {
    _endingView.frame = frame;
    _playAllButton.frame = CGRectMake(_endingView.frame.size.width / 3 - 100/2, _endingView.frame.size.height * 2 / 5 - 100/2, 100, 100);
    _replayEkisuButton.frame = CGRectMake(_endingView.frame.size.width * 2 / 3 - 100/2, _endingView.frame.size.height * 2 / 5 - 100/2, 100, 100);
}

- (void)setExtractSlider:(ABDEkisuSlider *)extractSlider {
    if (_extractSlider != extractSlider) {
        _extractSlider = extractSlider;
        [_bottomBar addSubview:_extractSlider];
        [_bottomBar sendSubviewToBack:_extractSlider];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.frame = _playerViewController.view.frame;   // update frame of view.
    [self adjustEndingView:self.frame];    // update endingView.

    // update bottomBar.
    self.bottomBar.frame = CGRectMake(0, _playerViewController.view.frame.size.height - kHeightOfBottomBar, _playerViewController.view.frame.size.width, kHeightOfBottomBar);
    if (self.isShowing) {
        self.bottomBar.alpha = 1.0f;
    } else {
        self.bottomBar.alpha = 0.0f;
    }
    _remainTimeLabel.frame = CGRectMake(_bottomBar.frame.size.width - kWidthOfRemainLabel - kPadding, kHeightOfBottomBar/2 - kHeightOfRemainLabel/2 , kWidthOfRemainLabel, kHeightOfRemainLabel);
    _extractSlider.frame = CGRectMake(0, 0, _bottomBar.frame.size.width, _bottomBar.frame.size.height);
    // update drawing section of ekisu for new frame
    [_extractSlider setNeedsDisplay];
}

- (void)setRemainTime:(NSTimeInterval)time {
    _remainTimeLabel.text = [Utility secondsToMMSS:time];
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self manageControlShowing];
}

- (void)manageControlShowing {
    self.isShowing ? [self hideControls:nil] : [self showControls:nil];
}

#pragma mark - control action

- (void)buttonPressed:(UIButton *)button {
    if (button == _playAllButton) {
        [_playerViewController replay:PlaymodeAll];      // play all of video.
    } else if (button == _replayEkisuButton) {
        [_playerViewController replay:PlaymodeEkisu];    // replay ekisu.
    }
    [self hideEndingView:YES];
}

- (void)hideEndingView:(BOOL)show {
    [_endingView setHidden:show];
}

- (void)showControls:(void(^)(void))completion {
    if (!self.isShowing) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControls:) object:nil];
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.bottomBar.alpha = 1.0f;
        } completion:^(BOOL finished) {
            _showing = YES;
            if (completion)
                completion();
            [self performSelector:@selector(hideControls:) withObject:nil afterDelay:5];
        }];
    } else {
        if (completion)
            completion();
    }
}

- (void)hideControls:(void(^)(void))completion {
    if (self.isShowing) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControls:) object:nil];
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            self.bottomBar.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _showing = NO;
            if (completion)
                completion();
        }];
    } else {
        if (completion)
            completion();
    }
}

@end
