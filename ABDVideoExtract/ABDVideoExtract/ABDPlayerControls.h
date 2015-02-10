//
//  ABDPlayerControls.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/4/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABDExtractSlider;
@class ABDPlayerViewController;

@interface ABDPlayerControls : UIView

@property (nonatomic, strong) ABDExtractSlider *extractSlider;
@property (nonatomic, strong) NSArray *extractSections;

- (id)initWithMoviePlayer:(ABDPlayerViewController *)moviePlayer;

- (void)hideEndingView:(BOOL)show;
@end