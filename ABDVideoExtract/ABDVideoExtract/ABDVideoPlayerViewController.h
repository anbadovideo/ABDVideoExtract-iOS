//
//  ABDVideoPlayerViewController.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "XCDYouTubeVideoPlayerViewController.h"

@class ABDVideoPlayerControls;

@interface ABDVideoPlayerViewController : XCDYouTubeVideoPlayerViewController
@property (nonatomic, strong) ABDVideoPlayerControls *controls;
@end
