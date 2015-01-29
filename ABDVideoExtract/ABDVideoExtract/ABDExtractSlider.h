//
//  ABDExtractSlider.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExtractSection;

@interface ABDExtractSlider : UISlider
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) NSArray *extractSections;

- (instancetype)initWithDuration:(NSTimeInterval)duration extractSections:(NSArray *)extractSections;
@end
