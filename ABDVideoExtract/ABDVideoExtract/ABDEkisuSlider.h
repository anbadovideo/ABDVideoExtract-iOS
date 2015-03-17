//
//  ABDExtractSlider.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EkisuSection;

@interface ABDEkisuSlider : UISlider
@property (nonatomic) NSTimeInterval duration;  // entire duration of video, not ekisu duration.
@property (nonatomic, strong) NSArray *ekisuSections;

- (instancetype)initWithDuration:(NSTimeInterval)duration extractSections:(NSArray *)extractSections;
@end
