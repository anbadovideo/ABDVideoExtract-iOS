//
//  ABDMoviePlayerController.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "XCDYouTubeVideoPlayerViewController.h"

@class ABDMoviePlayerControls;

@interface ABDMoviePlayerController : XCDYouTubeVideoPlayerViewController
@property (nonatomic, strong) ABDMoviePlayerControls *controls;
@end
