//
//  ABDMoviePlayerControls.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@class ABDExtractSlider;

@interface ABDMoviePlayerControls : UIView
@property (nonatomic, strong) ABDExtractSlider *extractSlider;
@end
