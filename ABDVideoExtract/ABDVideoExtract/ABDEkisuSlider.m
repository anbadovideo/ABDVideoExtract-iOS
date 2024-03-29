//
//  ABDExtractSlider.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/29/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDEkisuSlider.h"
#import "EkisuSection.h"

const int kHeightOfSlider = 44;

@interface ABDEkisuSlider ()
@property (nonatomic, strong) NSArray *markPositions;
@end

@implementation ABDEkisuSlider

- (id)init {
    self = [super init];
    if (self) {
        [self constructSlider];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self constructSlider];
    }
    return self;
}

- (instancetype)initWithDuration:(NSTimeInterval)duration extractSections:(NSArray *)extractSections {
    self = [super init];
    if (self) {
        _duration = duration;
        _ekisuSections = extractSections;
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

    [self setThumbImage:[UIImage imageNamed:@"slider_thumb.png"] forState:UIControlStateNormal];
}


- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    [self setNeedsDisplay];
}

- (void)setEkisuSections:(NSArray *)ekisuSections {
    // Todo : duration이 0이면 exception 처리.
    _ekisuSections = ekisuSections;
    [self setNeedsDisplay];
}

// override trackRectForBounds: for drawing custom tracks;
- (CGRect)trackRectForBounds:(CGRect)bounds {
    return bounds;
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
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.4 alpha:1.0f] CGColor]);
    CGContextStrokePath(context);
    UIImage *selectedSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    // Unselected side
    CGContextSetLineWidth(context, kHeightOfSlider);
    CGContextMoveToPoint(context, 0, CGRectGetHeight(innerRect)/2);
    CGContextAddLineToPoint(context, innerRect.size.width, CGRectGetHeight(innerRect)/2);
    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.15 alpha:1.0f] CGColor]);
    CGContextStrokePath(context);
    UIImage *unselectedSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    // duration이 0일때는 일단 패스.
    if (_duration <= 0)
        return;

    // Set trips on selected side
    [selectedSide drawAtPoint:CGPointMake(0,0)];
    for (int i = 0; i < [_ekisuSections count]; i++) {
        CGContextSetLineWidth(context, kHeightOfSlider);
        float startPosition = (float)([_ekisuSections[i] startTime] / _duration) * self.frame.size.width;
        float endPosition = (float)([_ekisuSections[i] endTime] / _duration) * self.frame.size.width;
        CGContextMoveToPoint(context, startPosition, CGRectGetHeight(innerRect)/2);
        CGContextAddLineToPoint(context, endPosition, CGRectGetHeight(innerRect)/2);
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0.24 green:0.68 blue:0.85 alpha:1.0f] CGColor]);
        CGContextStrokePath(context);
    }
    UIImage *selectedStripSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    // Set trips on unselected side
    [unselectedSide drawAtPoint:CGPointMake(0,0)];
    for (int i = 0; i < [_ekisuSections count]; i++) {
        CGContextSetLineWidth(context, kHeightOfSlider);
        float startPosition = (float)([_ekisuSections[i] startTime] / _duration) * self.frame.size.width;
        float endPosition = (float)([_ekisuSections[i] endTime] / _duration) * self.frame.size.width;
        CGContextMoveToPoint(context, startPosition, CGRectGetHeight(innerRect)/2);
        CGContextAddLineToPoint(context, endPosition, CGRectGetHeight(innerRect)/2);
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:0.24 green:0.68 blue:0.85 alpha:0.5f] CGColor]);
        CGContextStrokePath(context);
    }
    UIImage *unselectedStripSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    UIGraphicsEndImageContext();

    [self setMinimumTrackImage:selectedStripSide forState:UIControlStateNormal];
    [self setMaximumTrackImage:unselectedStripSide forState:UIControlStateNormal];
}

@end
