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

const static int kHeightOfBottomBar = 44;

@interface ABDVideoPlayerControls ()
@property (nonatomic, weak) ABDVideoPlayerViewController *playerViewController;
@property (nonatomic, getter = isShowing) BOOL showing;

@property (nonatomic, strong) NSTimer *durationTimer;

@property (nonatomic, strong) UIView *activityBackgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIView *bottomBar;

@end

@implementation ABDVideoPlayerControls

- (id)initWithMoviePlayer:(ABDVideoPlayerViewController *)playerViewController {
    self = [super init];
    if (self) {
        [self setup];

        _playerViewController = playerViewController;
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

    self.bottomBar.frame = CGRectMake(0, self.frame.size.height - kHeightOfBottomBar, self.frame.size.width, kHeightOfBottomBar);
    _extractSlider.frame = CGRectMake(0, 0, _bottomBar.frame.size.width, _bottomBar.frame.size.height);
}
@end
