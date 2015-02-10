//
//  ABDPlayerControls.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/4/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDPlayerControls.h"
#import "ABDExtractSlider.h"
#import "ABDPlayerViewController.h"

const static int kHeightOfBottomBar = 44;

@interface ABDPlayerControls ()
@property (nonatomic, weak) ABDPlayerViewController *playerViewController;

@property (nonatomic, getter = isShowing) BOOL showing;

@property (nonatomic, strong) NSTimer *durationTimer;

@property (nonatomic, strong) UIView *bottomBar;

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

- (void)buttonPressed:(UIButton *)button {
    if (button == _playAllButton) {
        [_playerViewController replay:PlaymodeAll];      // play all of video.
    } else if (button == _replayEkisuButton) {
        [_playerViewController replay:PlaymodeEkisu];    // replay ekisu.
    }
    [self hideEndingView:YES];
}

- (void)adjustEndingView:(CGRect)frame {
    _endingView.frame = frame;
    _playAllButton.frame = CGRectMake(self.frame.size.width / 3 - 100/2, self.frame.size.height * 2 / 5 - 100/2, 100, 100);
    _replayEkisuButton.frame = CGRectMake(self.frame.size.width * 2 / 3 - 100/2, self.frame.size.height * 2 / 5 - 100/2, 100, 100);
}

- (void)hideEndingView:(BOOL)show {
    [_endingView setHidden:show];
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

    [self adjustEndingView:screenBound];

    self.bottomBar.frame = CGRectMake(0, screenBound.size.height - kHeightOfBottomBar, screenBound.size.width, kHeightOfBottomBar);
    _extractSlider.frame = CGRectMake(0, 0, _bottomBar.frame.size.width, _bottomBar.frame.size.height);
    [_extractSlider setNeedsDisplay];
}
@end
