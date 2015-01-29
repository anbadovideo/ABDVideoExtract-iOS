//
//  ABDExtractSlider.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDExtractSlider.h"
#import "ExtractSection.h"

const int kHeightOfSlider = 44;

@interface ABDExtractSlider ()
@property (nonatomic, strong) NSArray *markPositions;
@end

@implementation ABDExtractSlider

- (id)init {
    self = [super init];
    if (self) {
        [self constructSlider];
    }
    return self;
}

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
//    self.maximumValue = 1.0f;
    self.value = 0.0f;

    self.continuous = YES;

    [self setMaximumTrackImage:[UIImage imageNamed:@"slider_deactive.png"] forState:UIControlStateNormal];
    [self setMinimumTrackImage:[UIImage imageNamed:@"slider_active.png"] forState:UIControlStateNormal];
    [self setThumbImage:[UIImage imageNamed:@"slider_thumb.png"] forState:UIControlStateNormal];
}

- (void)setMaximumValue:(float)maximumValue {
    [super setMaximumValue:maximumValue];

    // override setMaximumValue:
    _duration = maximumValue;
    [self setNeedsDisplay];
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    [self setNeedsDisplay];
}

- (void)setExtractSections:(NSArray *)extractSections {
    // Todo : duration이 0이면 exception 처리.
    _extractSections = extractSections;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    // We create an innerRect in which we paint the lines
    CGRect innerRect = CGRectInset(rect, 0.0, 00.0);

    UIGraphicsBeginImageContextWithOptions(innerRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Selected side
    CGContextSetLineWidth(context, kHeightOfSlider);
    CGContextMoveToPoint(context, 0, CGRectGetHeight(innerRect)/2);
    CGContextAddLineToPoint(context, innerRect.size.width, CGRectGetHeight(innerRect)/2);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextStrokePath(context);
    UIImage *selectedSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    // Unselected side
    CGContextSetLineWidth(context, kHeightOfSlider);
    CGContextMoveToPoint(context, 0, CGRectGetHeight(innerRect)/2);
    CGContextAddLineToPoint(context, innerRect.size.width, CGRectGetHeight(innerRect)/2);
    CGContextSetStrokeColorWithColor(context, [[UIColor darkGrayColor] CGColor]);
    CGContextStrokePath(context);
    UIImage *unselectedSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    // duration이 0일때는 일단 패스.
    if (_duration <= 0)
        return;

    // Set trips on selected side
    [selectedSide drawAtPoint:CGPointMake(0,0)];
    for (int i = 0; i < [_extractSections count]; i++) {
        CGContextSetLineWidth(context, kHeightOfSlider);
        float startPosition = (float)([_extractSections[i] startTime] / _duration) * self.frame.size.width;
        float endPosition = (float)([_extractSections[i] endTime] / _duration) * self.frame.size.width;
        CGContextMoveToPoint(context, startPosition, CGRectGetHeight(innerRect)/2);
        CGContextAddLineToPoint(context, endPosition, CGRectGetHeight(innerRect)/2);
        CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
        CGContextStrokePath(context);
    }
    UIImage *selectedStripSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    // Set trips on unselected side
    [unselectedSide drawAtPoint:CGPointMake(0,0)];
    for (int i = 0; i < [_extractSections count]; i++) {
        CGContextSetLineWidth(context, kHeightOfSlider);
        float startPosition = (float)([_extractSections[i] startTime] / _duration) * self.frame.size.width;
        float endPosition = (float)([_extractSections[i] endTime] / _duration) * self.frame.size.width;
        CGContextMoveToPoint(context, startPosition, CGRectGetHeight(innerRect)/2);
        CGContextAddLineToPoint(context, endPosition, CGRectGetHeight(innerRect)/2);
        CGContextSetStrokeColorWithColor(context, [[UIColor cyanColor] CGColor]);
        CGContextStrokePath(context);
    }
    UIImage *unselectedStripSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    UIGraphicsEndImageContext();

    [self setMinimumTrackImage:selectedStripSide forState:UIControlStateNormal];
    [self setMaximumTrackImage:unselectedStripSide forState:UIControlStateNormal];
}

@end
