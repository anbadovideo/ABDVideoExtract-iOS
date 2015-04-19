//
//  ABDKakaoActivity.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 4/20/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDKakaoActivity.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@implementation ABDKakaoActivity {
    NSString *_message;
    NSURL *_imageUrl;
}

- (NSString *)activityType {
    return @"KakaoActivity";
}

- (NSString *)activityTitle {
    return @"카카오톡";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"kakaoIcon"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    KakaoTalkLinkObject *label
            = [KakaoTalkLinkObject createLabel:_message];

    KakaoTalkLinkObject *image
            = [KakaoTalkLinkObject createImage:[_imageUrl absoluteString]
                                         width:138
                                        height:80];

    if ([KOAppCall canOpenKakaoTalkAppLink]) {
        [KOAppCall openKakaoTalkAppLink:@[label, image]];
    }

    [self activityDidFinish:YES];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]] && !_message)
            _message = item;
        else if ([item isKindOfClass:[NSURL class]] && !_imageUrl)
            _imageUrl = item;
    }
}

@end