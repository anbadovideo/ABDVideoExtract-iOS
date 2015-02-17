//
//  ABDPlayerViewController.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 2/4/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    PlaymodeEkisu,
    PlaymodeAll
} Playmode;

@class AVPlayer;
@class ABDPlaybackView;
@class ABDPlayerControls;

@interface ABDPlayerViewController : UIViewController {
    id timeObserver;
    NSInteger _sectionCounter;   // for check playing extract section.
}
@property (nonatomic, strong) NSString* identifier; // video id
@property (nonatomic, strong, setter=setPlayer:, getter=player) AVPlayer *player;
@property (strong) AVPlayerItem *playerItem;
@property (nonatomic) Playmode playmode;

@property (nonatomic, strong) ABDPlaybackView *playbackView;
@property (nonatomic, strong) ABDPlayerControls *controls;
@property (nonatomic, strong) NSArray *extractSections;
@property (nonatomic) NSTimeInterval extractDuration;

- (instancetype)initWithIdentifier:(NSString *)identifier;

- (void)replay:(Playmode)mode;
@end