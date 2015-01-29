//
//  ABDMoviePlayerControls.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDMoviePlayerControls.h"
#import "ABDExtractSlider.h"
#import "ABDMoviePlayerController.h"

@interface ABDMoviePlayerControls ()
@property (nonatomic, weak) ABDMoviePlayerController *moviePlayer;
@property (nonatomic, getter = isShowing) BOOL showing;

@property (nonatomic, strong) UIView *activityBackgroundView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UIView *bottomBar;

@end

@implementation ABDMoviePlayerControls

- (id)init {
    self = [super init];
    if (self) {
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

    self.bottomBar.frame = CGRectMake(0, self.frame.size.height - 44, self.frame.size.width, 44);
    _extractSlider.frame = CGRectMake(0, 0, _bottomBar.frame.size.width, _bottomBar.frame.size.height);
}
@end
