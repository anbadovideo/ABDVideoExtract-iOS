//
//  ABDProgressView.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 3/4/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#include <UIKit/UIKit.h>

@interface ABDEkisuProgressView : UIView

/**@name Properties*/
/**Wether or not the progress view is indeterminate.*/
@property (nonatomic, assign) BOOL indeterminate;
/**The durations of animations in seconds.*/
@property (nonatomic, assign) CGFloat animationDuration;
/**The progress displayed to the user.*/
@property (nonatomic, readonly) CGFloat progress;

/**The image to use when showing progress.*/
@property (nonatomic, retain) UIImage *progressImage;
/**Wether or not to draw the greyscale background.*/
@property (nonatomic, assign) BOOL drawGreyscaleBackground;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
