//
//  ABDExtractSlider.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDExtractSlider.h"

@implementation ABDExtractSlider
- (instancetype)initWithDuration:(NSTimeInterval)duration extractSections:(NSArray *)extractSections {
    self = [super init];
    if (self) {
        _duration = duration;
        _extractSections = extractSections;
        [self constructSlider];
    }
    return self;
}

- (void)constructSlider {
    _duration = 0;

    // set valuee range of slider 0 to 1
    self.minimumValue = 0.0f;
    self.maximumValue = 1.0f;
    self.value = 0.0f;
}
@end
