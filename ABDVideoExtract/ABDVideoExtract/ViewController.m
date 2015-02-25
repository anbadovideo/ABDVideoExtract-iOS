//
//  ViewController.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/27/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ViewController.h"

@interface ABDEkisuCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *ekisuThumbView;
@property (nonatomic, strong) IBOutlet UIImageView *ekisuThumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *ekisuTitleLabel;
@property (nonatomic, strong) IBOutlet UIView *ekisuRateView;
@end

@implementation ABDEkisuCell
- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];

    self.ekisuTitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.ekisuTitleLabel.frame);
    [self.ekisuTitleLabel sizeToFit];
}
@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    _ekisus = @[@"1oDAuUx3m6U", @"1oDAuUx3m6U"];

//    self.tableView.estimatedRowHeight = 314.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Do view manipulation here.
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - TableView DataSource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_ekisus count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifer = @"ABDEkisuCell";
    ABDEkisuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];

    [cell.ekisuThumbnailImageView setImage:[UIImage imageNamed:@"slider_active@2x.png"]];
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

}


@end