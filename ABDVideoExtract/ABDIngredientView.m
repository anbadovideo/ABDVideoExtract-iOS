//
//  ABDIngredientView.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 3/10/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ABDIngredientView.h"
#import "UIImageView+AFNetworking.h"
#import "Ekisu.h"
#import "Video.h"

@interface ABDIngredientView ()
@property (strong, nonatomic) IBOutlet UILabel *rateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *videoURLLabel;

@end

@implementation ABDIngredientView

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.layer.cornerRadius = 15;
    self.view.layer.masksToBounds = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [_videoImageView setImageWithURL:[NSURL URLWithString:_ekisu.video.thumbnail] placeholderImage:nil];
    [_videoURLLabel setText:[NSString stringWithFormat:@"http://youtu.be/%@", _ekisu.video.identifier]];
    [_videoTitleLabel setText:_ekisu.video.title];
}

@end
