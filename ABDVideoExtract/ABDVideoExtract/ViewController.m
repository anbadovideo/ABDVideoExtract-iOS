//
//  ViewController.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/27/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ViewController.h"
#import "ABDVideoPlayerViewController.h"
#import "XCDYouTubeVideo.h"
#import "ABDVideoPlayerControls.h"
#import "ABDExtractSlider.h"
#import "ExtractSection.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    ExtractSection *section1 = [[ExtractSection alloc] initWithStartTime:9.1f endTime:12.0f];
    ExtractSection *section2 = [[ExtractSection alloc] initWithStartTime:90.2f endTime:100.0f];
    ExtractSection *section3 = [[ExtractSection alloc] initWithStartTime:190.3f endTime:200.0f];
    ExtractSection *section4 = [[ExtractSection alloc] initWithStartTime:290.4f endTime:300.0f];
    NSArray *sections = @[section1, section2, section3, section4];

    ABDVideoPlayerViewController *moviePlayerController = [[ABDVideoPlayerViewController alloc] initWithVideoIdentifier:@"S3wBmsi03IU"];
    [moviePlayerController presentInView:self.view];
    [self.view sendSubviewToBack:moviePlayerController.view];

    ABDVideoPlayerControls *playerControls = [[ABDVideoPlayerControls alloc] initWithMoviePlayer:moviePlayerController];
    [playerControls setExtractSections:sections];

    ABDExtractSlider *extractSlider = [[ABDExtractSlider alloc] init];
    [extractSlider setExtractSections:sections];
    [playerControls setExtractSlider:extractSlider];

    [moviePlayerController setControls:playerControls];

    [moviePlayerController.moviePlayer stop];
    moviePlayerController.preferredVideoQualities = @[@(XCDYouTubeVideoQualityHD720), @(XCDYouTubeVideoQualityMedium360), @(XCDYouTubeVideoQualitySmall240)];
    moviePlayerController.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    moviePlayerController.moviePlayer.initialPlaybackTime = [section1 startTime];
    [moviePlayerController.moviePlayer play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
