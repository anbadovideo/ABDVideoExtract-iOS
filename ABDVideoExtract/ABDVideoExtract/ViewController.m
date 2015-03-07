//
//  ViewController.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/27/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "ViewController.h"
#import "ABDPlayerViewController.h"
#import "ABDPlayerControls.h"
#import "ABDEkisuProgressView.h"
#import "AppDelegate.h"
#import "Ekisu.h"
#import "Video.h"
#import "UIImageView+AFNetworking.h"
#import <AFNetworking/AFNetworking.h>

@interface ABDEkisuCell : UITableViewCell
@property(strong, nonatomic) IBOutlet UIView *ekisuThumbView;
@property(nonatomic, strong) IBOutlet UIImageView *ekisuThumbnailImageView;
@property(nonatomic, strong) IBOutlet UILabel *ekisuTitleLabel;
@property(nonatomic, strong) IBOutlet UIView *ekisuRateView;
@property(nonatomic, strong) IBOutlet ABDEkisuProgressView *ekisuProgressView;
@end

@implementation ABDEkisuCell
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initUI];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initUI];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self initUI];
}

- (void)initUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [_ekisuProgressView setProgressImage:[UIImage imageNamed:@"progressBg.png"]];
    _ekisuProgressView.drawGreyscaleBackground = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];

    self.ekisuTitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.ekisuTitleLabel.frame);
    [self.ekisuTitleLabel sizeToFit];
}
@end

@interface ViewController ()
@property(nonatomic, strong) ABDPlayerViewController *playerViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _ekisus = [[NSMutableArray alloc] init];

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSString *urlString = [NSString stringWithFormat:@"%@/ekisus/", appDelegate.serverURL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        for (NSDictionary *ekisuDictionary in responseObject[@"results"]) {
            Ekisu *ekisu = [[Ekisu alloc] initWithDictionary:ekisuDictionary];
            [_ekisus addObject:ekisu];
        }
        [self.tableView reloadData];
    }    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Load Ekisus"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];

    _playerViewController = [[ABDPlayerViewController alloc] init];     // playerViewController initializing.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    // Do view manipulation here.
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - TableView DataSource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
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

    Ekisu *ekisu = _ekisus[(NSUInteger) [indexPath row]];
    [cell.ekisuThumbnailImageView setImageWithURL:[NSURL URLWithString:ekisu.thumbnail] placeholderImage:nil];
    [cell.ekisuTitleLabel setText:ekisu.title];
    [cell.ekisuProgressView setProgress:random() % 100 * 0.01 animated:YES];

    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    Ekisu *ekisu = _ekisus[(NSUInteger) [indexPath row]];
    NSString *videoIdentifier = ekisu.video.identifier;
    if ([_playerViewController isPlaying] && [videoIdentifier isEqualToString:[_playerViewController identifier]]) {
        [_playerViewController.controls manageControlShowing];  // control panel showing
    } else {
        [_playerViewController.player pause];

        [_playerViewController setIdentifier:videoIdentifier]; // 해당 인덱스의 영상id 변경
        ABDEkisuCell *cell = (ABDEkisuCell *) [self.tableView cellForRowAtIndexPath:indexPath];
        [_playerViewController setFrame:cell.ekisuThumbView.bounds];    // 해당 셀의 위치에 맞게 플레이어 뷰의 프레임을 조정
        [cell.ekisuThumbView addSubview:_playerViewController.view];
        [_playerViewController.view becomeFirstResponder];              // 동영상 플레이어가 가장 이벤트처리를 먼저하도록 수정
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

}


@end