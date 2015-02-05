//
//  ABDPlayerControls.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/4/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDPlayerControls.h"

const static int kHeightOfBottomBar = 44;

@interface ABDPlayerControls ()
@property (nonatomic, weak) ABDPlayerViewController *playerViewController;

@property (nonatomic, getter = isShowing) BOOL showing;

@property (nonatomic, strong) NSTimer *durationTimer;

@property (nonatomic, strong) UIView *bottomBar;

@end

@implementation ABDPlayerControls

@end
