//
//  ABDPlayerControls.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/4/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDPlayerControls.h"
#import "ABDExtractSlider.h"

const static int kHeightOfBottomBar = 44;

@interface ABDPlayerControls ()
@property (nonatomic, weak) ABDPlayerViewController *playerViewController;

@property (nonatomic, getter = isShowing) BOOL showing;

@property (nonatomic, strong) NSTimer *durationTimer;

@property (nonatomic, strong) UIView *bottomBar;

@end

@implementation ABDPlayerControls

- (id)initWithMoviePlayer:(ABDPlayerViewController *)playerViewController {
    self = [super init];
    if (self) {\
        _playerViewController = playerViewController;

        [self setup];
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
    [_extractSlider setNeedsDisplay];
}
@end
