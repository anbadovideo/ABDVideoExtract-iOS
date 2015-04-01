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
#import "ABDEkisuRateView.h"
#import "AppDelegate.h"
#import "Ekisu.h"
#import "Video.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "ABDEkisuIngredientViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <CCMPopup/CCMPopupSegue.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface ABDEkisuCell : UITableViewCell
@property(nonatomic, strong) IBOutlet UIImageView *playableImageView;
@property(nonatomic, strong) IBOutlet UIView *ekisuThumbView;
@property(nonatomic, strong) IBOutlet UIImageView *ekisuThumbnailImageView;
@property(nonatomic, strong) IBOutlet UILabel *ekisuTitleLabel;
@property(nonatomic, strong) IBOutlet UIView *ekisuRateContainerView;
@property(nonatomic, strong) IBOutlet ABDEkisuRateView *ekisuRateView;
@property(nonatomic, strong) IBOutlet UIButton *ekisuRateButton;
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

    [_ekisuRateView setProgressImage:[UIImage imageNamed:@"progressBg.png"]];
    _ekisuRateView.drawGreyscaleBackground = YES;
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
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) MBProgressHUD *loadingView;
@property(nonatomic, strong) NSString *requestURLString;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"EkisuViewController";

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.24 green:0.68 blue:0.85 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:17]};

    // show App Intro
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowingIntro"] == NO) {
        [self showIntro];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

    _loadingView = [[MBProgressHUD alloc] initWithFrame:self.tableView.frame];
    _loadingView.color = [UIColor colorWithWhite:0.4 alpha:1.0f];
    [self.tableView addSubview:_loadingView];

    [self initURLString];

    _playerViewController = [[ABDPlayerViewController alloc] init];     // playerViewController initializing.

    _ekisus = [[NSMutableArray alloc] init];

    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];

    [self loadDataFromServer];

    // tableView paging.
    __weak typeof(self)weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadDataFromServer];
    }];
}

- (void)refreshData {
    [self initURLString];
    [_ekisus removeAllObjects];
    [self.tableView reloadData];
    [self loadDataFromServer];
}

- (void)initURLString {
    // set URL to initial request URL
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _requestURLString = [NSString stringWithFormat:@"%@/ekisus/", appDelegate.serverURL];
}

- (void)loadDataFromServer {
    if (_requestURLString == nil) {
        // invalid request
        [self.tableView.infiniteScrollingView stopAnimating];
        return;
    }

    [_loadingView show:YES];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:_requestURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@", responseObject);
        [_loadingView hide:YES];
        if ([responseObject[@"results"] count] == 0) {
            self.tableView.showsInfiniteScrolling = NO;
            return;
        }

        if (responseObject[@"next"] != [NSNull null]) {
            _requestURLString = responseObject[@"next"];
        } else {
            _requestURLString = nil;
        }

        int currentRow = [_ekisus count];

        for (NSDictionary *ekisuDictionary in responseObject[@"results"]) {
            Ekisu *ekisu = [[Ekisu alloc] initWithDictionary:ekisuDictionary];
            [_ekisus addObject:ekisu];
        }
        [self reloadTableView:currentRow];

        // stop scrolling or refreshing
        [_refreshControl endRefreshing];
        [self.tableView.infiniteScrollingView stopAnimating];

    }    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Load Ekisus"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [_refreshControl endRefreshing];
        self.tableView.showsInfiniteScrolling = NO;
    }];
}

- (void)reloadTableView:(int)startingRow {
    // the last row after added new items
    int endingRow = [_ekisus count];

    NSMutableArray *indexPaths = [NSMutableArray array];
    for (; startingRow < endingRow; startingRow++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startingRow inSection:0]];
    }

    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    // Do view manipulation here.
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    NSLog(@"rotation");
}

#pragma mark - Intro

- (void)showIntro {
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"재밌는 영상, 이제 엑기스만 보세요.";
    page1.titleColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page1.desc = @"재밌는 영상들을 볼 시간이 없는 바쁜 현대인들을 위해\n 직접 엄선하여 화제의 영상을 엑기스만 짜서 보여드립니다.\n엑기스만 보고 여러분의 시간을 절약하세요!";
    page1.descColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page1"]];

    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"푸시를 허용해주세요.";
    page2.titleColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page2.desc = @"여러분들에게 재밌는 엑기스들을 매일 배달해 드려요.\n귀찮게 하지 않을거예요.";
    page2.descColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page2"]];

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.navigationController.view.bounds andPages:@[page1,page2]];
    intro.backgroundColor = [UIColor whiteColor];
    [intro setShowSkipButtonOnlyOnLastPage:YES];
    [intro setDelegate:self];

    [intro showInView:self.navigationController.view animateDuration:0.3];
}

- (void)introDidFinish:(EAIntroView *)introView {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowingIntro"];

    // intro 끝난 이후에 푸시 등록 요청.
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    }
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    if ([segue isKindOfClass:[CCMPopupSegue class]]){
        [self trackingEvent:@"button_press" label:@"ekisuRate_show"];

        CCMPopupSegue *popupSegue = (CCMPopupSegue *)segue;
        popupSegue.destinationBounds = CGRectMake(0, 0, 320, 292);
        popupSegue.backgroundViewAlpha = 1.0f;
        popupSegue.backgroundViewColor = [UIColor colorWithWhite:0.1 alpha:0.7];
        popupSegue.dismissableByTouchingBackground = YES;

        Ekisu *ekisu = _ekisus[[(UIButton *)sender tag]];
        [[segue destinationViewController] setEkisu:ekisu];
    }
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
    [cell.ekisuThumbnailImageView setImageWithURL:[NSURL URLWithString:ekisu.thumbnail] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [cell.ekisuTitleLabel setText:ekisu.title];

    // calculate rate of ekisu
    [cell.ekisuRateView setProgress:ekisu.concentrationRate animated:YES];
    [cell.ekisuRateButton setTag:[indexPath row]];  // set tag of button to indexPath row.

    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    Ekisu *ekisu = _ekisus[(NSUInteger) [indexPath row]];
    if ([_playerViewController isPlaying] && [ekisu.ekisuId isEqualToString:_playerViewController.ekisu.ekisuId]) {
        [_playerViewController.controls manageControlShowing];  // control panel showing
    } else {
        [self trackingEvent:@"cell_press" label:@"newVideo_watch"];

        [_playerViewController.player pause];
        [_playerViewController.view removeFromSuperview];

        [_playerViewController setEkisu:ekisu];
        ABDEkisuCell *cell = (ABDEkisuCell *) [self.tableView cellForRowAtIndexPath:indexPath];
        [_playerViewController setFrame:cell.ekisuThumbView.bounds];    // 해당 셀의 위치에 맞게 플레이어 뷰의 프레임을 조정
        [cell.ekisuThumbView addSubview:_playerViewController.view];
        [_playerViewController.view becomeFirstResponder];              // 동영상 플레이어가 가장 이벤트처리를 먼저하도록 수정

        [_playerViewController showPlayerView:NO]; // 재생 준비 전까지 숨김.
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // remove player view.
    ABDEkisuCell *ekisuCell = (ABDEkisuCell *)cell;
    if (ekisuCell.ekisuThumbView == [_playerViewController.view superview]) {
        // 사라지는 셀 위에 현재 재생 중인 플레이어의 뷰가 존재하면
        [_playerViewController.player pause];
        [_playerViewController.view removeFromSuperview];
    }
}

#pragma mark - Google Analytics Method

- (void)trackingEvent:(NSString *)action label:(NSString *)label {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:self.screenName];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
}
@end