//
//  ABDMoviePlayerController.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <objc/runtime.h>
#import "ABDMoviePlayerController.h"
#import "ABDMoviePlayerControls.h"

@implementation ABDMoviePlayerController

- (void)setControls:(ABDMoviePlayerControls *)controls {
    if (_controls != controls) {
        _controls = controls;
        _controls.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.view addSubview:_controls];
    }
}

- (void)presentInView:(UIView *)view
{
    /* 기존의 코드에서 moviePlayer의 controlStyle 값을 바꾸기 위해 클래스 상속으로 별도 처리.
    * */
    static void *XCDYouTubeVideoPlayerViewControllerKey = &XCDYouTubeVideoPlayerViewControllerKey;

//    super.embedded = YES;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.view.frame = CGRectMake(0.f, 0.f, view.bounds.size.width, view.bounds.size.height);
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (![view.subviews containsObject:self.moviePlayer.view])
        [view addSubview:self.moviePlayer.view];
    objc_setAssociatedObject(view, XCDYouTubeVideoPlayerViewControllerKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
