//
//  ABDIngredientView.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 3/10/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDEkisuIngredientViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Ekisu.h"
#import "Video.h"
#import "ABDEkisuSlider.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface ABDEkisuIngredientViewController ()
@property (strong, nonatomic) IBOutlet UILabel *rateLabel;
@property (strong, nonatomic) IBOutlet UIView *ingredientView;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoURLLabel;

@end

@implementation ABDEkisuIngredientViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    ABDEkisuSlider *ekisuSlider = [[ABDEkisuSlider alloc] initWithFrame:_ingredientView.bounds];
    ekisuSlider.duration = [_ekisu.video.duration doubleValue];
    ekisuSlider.ekisuSections = _ekisu.sections;
    ekisuSlider.value = 1.0;    // to highlighting slider
    ekisuSlider.userInteractionEnabled = NO;
    [_ingredientView addSubview:ekisuSlider];

    [_videoImageView setImageWithURL:[NSURL URLWithString:_ekisu.video.thumbnail] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_videoURLLabel setText:[NSString stringWithFormat:@"http://youtu.be/%@", _ekisu.video.identifier]];
    [_videoTitleLabel setText:_ekisu.video.title];

    [_rateLabel setText:[NSString stringWithFormat:@"%d%%", (int) (_ekisu.concentrationRate * 100)]];
    [_rateLabel sizeToFit];
}

@end
