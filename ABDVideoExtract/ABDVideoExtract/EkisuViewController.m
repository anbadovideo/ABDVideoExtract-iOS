//
//  ViewController.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/27/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "EkisuViewController.h"
#import "ABDPlayerViewController.h"
#import "ABDPlayerControls.h"
#import "ABDEkisuRateView.h"
#import "AppDelegate.h"
#import "Ekisu.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
#import <QuartzCore/QuartzCore.h>
#import <CCMPopup/CCMPopupSegue.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "ABDKakaoActivity.h"

@interface ABDEkisuCell : UITableViewCell
@property(nonatomic, strong) IBOutlet UIImageView *playableImageView;
@property(nonatomic, strong) IBOutlet UIView *ekisuThumbView;
@property(nonatomic, strong) IBOutlet UIImageView *ekisuThumbnailImageView;
@property(nonatomic, strong) IBOutlet UILabel *ekisuTitleLabel;
@property(nonatomic, strong) IBOutlet UIButton *shareButton;
@property(nonatomic, strong) IBOutlet UILabel *indexLabel;
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

    self.shareButton.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.shareButton.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.shareButton.layer.shadowRadius = 0.0;
    self.shareButton.layer.shadowOpacity = 1.0f;
    self.shareButton.layer.masksToBounds = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];

    self.ekisuTitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.ekisuTitleLabel.frame);
    [self.ekisuTitleLabel sizeToFit];
}
@end

@interface EkisuViewController ()
@property(nonatomic, strong) ABDPlayerViewController *playerViewController;
@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) MBProgressHUD *loadingView;
@property(nonatomic, strong) NSString *requestURLString;
@end

@implementation EkisuViewController

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
    [self.view addSubview:_loadingView];

    [self initURLString];

    _playerViewController = [[ABDPlayerViewController alloc] init];     // playerViewController initializing.

    _ekisus = [[NSMutableArray alloc] init];

    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];

    // drawer menu에서 직접 테이블뷰 새로고침을 위한 노티피케이션 등록.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableWithNotification:) name:@"RefreshTable" object:nil];
    // drawer menu에서 메일 보내기를 위한 노티피케이션 등록.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMail:) name:@"SendMail" object:nil];

    [self loadDataFromServer];

    // tableView paging.
    __weak typeof(self)weakSelf = self;
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadDataFromServer];
    }];
}

- (void)refreshTableWithNotification:(NSNotification *)notification {
    self.navigationItem.title = notification.userInfo[@"category__fullTitle"];
    _categoryTitle = notification.userInfo[@"category__title"];
    [self refreshData];
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

    if (_categoryTitle != nil && ![@"" isEqualToString:_categoryTitle])
        _requestURLString = [NSString stringWithFormat:@"%@/ekisus/?category__title=%@", appDelegate.serverURL, _categoryTitle];
    else
        _requestURLString = [NSString stringWithFormat:@"%@/ekisus/", appDelegate.serverURL];
    NSLog(@"%@", _requestURLString);
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
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {

    } completion:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            [self.tableView setContentOffset:CGPointMake(0.0, self.tableView.contentSize.height - self.tableView.bounds.size.height - self.navigationController.navigationBar.frame.size.height)
                           animated:NO];
        } else {
        }
        [self.tableView scrollToRowAtIndexPath:[self indexPathForCurrentPlaying] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }];
}

#pragma mark - Slide Navigation Delegate

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

#pragma mark - mail compose

- (void)sendMail:(NSNotification *)notification {
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    mail.mailComposeDelegate = self;
    [mail setSubject:@"영상엑기스에 문의하기"];
    [mail setMessageBody:[NSString stringWithFormat:@"\n\n개선되길 원하거나 바라는 점 : \n\n\n\n우리팀 엑기스 요청하기(요청이 많이 들어오는 팀을 우선 반영해드릴 예정이에요) : "]
                  isHTML:NO];
    [mail setToRecipients:@[@"connect@anbado.com"]];
    [self presentViewController:mail animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Intro

- (void)showIntro {
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"야구 하이라이트, 이제 영상엑기스에서 보세요";
    page1.titleColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page1.desc = @"우리팀의 활약상, 네이버 하이라이트만으론 부족할 때,\n 우리팀 팬들 찍은 직관 영상들을 보고플 때,\n 영상엑기스가 팬심을 담아 모아서 보여드립니다.\n ";
    page1.descColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page1"]];

    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"팬이라면 깨알같은 장면도 놓칠 수 없는 법";
    page2.titleColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page2.desc = @"단순한 경기 내용이 아니라 재밌는 장면도 보세요.\n 아, 간단하게 공유버튼을 통해 친구들에게도 보여줄 수 있어요.";
    page2.descColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page2"]];

    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"푸시를 허용해주세요.";
    page3.titleColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page3.desc = @"여러분들에게 팬심 가득한 하이라이트 영상을 매일 배달해 드려요.\n귀찮게 하진 않을거예요.";
    page3.descColor = [UIColor colorWithWhite:0.3 alpha:1.0f];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"page3"]];

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.navigationController.view.bounds andPages:@[page1,page2,page3]];
    intro.backgroundColor = [UIColor whiteColor];
    [intro setShowSkipButtonOnlyOnLastPage:YES];
    [intro setDelegate:self];
    intro.pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    intro.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([_ekisus count] == 0)
        return tableView.frame.size.height;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height)];

    UIImageView *emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emptyEkisu"]];
    emptyImageView.center = CGPointMake(CGRectGetMidX(emptyView.frame), CGRectGetMidY(emptyView.frame) - 100);

    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, emptyImageView.frame.origin.y + emptyImageView.frame.size.height + 30, emptyView.bounds.size.width, 21)];
    infoLabel.textColor = [UIColor darkGrayColor];
    infoLabel.text = [NSString stringWithFormat:@"아직 엑기스가 없네요 %@", @"\U0001F625"];
    infoLabel.font = [UIFont systemFontOfSize:15];
    infoLabel.textAlignment = NSTextAlignmentCenter;

    UIButton *sendRequestButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMidX(infoLabel.frame) - 120/2, infoLabel.frame.origin.y + infoLabel.frame.size.height + 30, 120, 30)];
    [sendRequestButton setTitle:@"우리 팀 요청하기" forState:UIControlStateNormal];
    [sendRequestButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendRequestButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    sendRequestButton.backgroundColor = [UIColor darkGrayColor];
    sendRequestButton.layer.cornerRadius = 5;
    sendRequestButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    sendRequestButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    sendRequestButton.tag = 1;
    [sendRequestButton addTarget:self action:@selector(sendMail:) forControlEvents:UIControlEventTouchUpInside];

    [emptyView addSubview:infoLabel];
    [emptyView addSubview:emptyImageView];
    [emptyView addSubview:sendRequestButton];
    return emptyView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifer = @"ABDEkisuCell";
    ABDEkisuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];

    Ekisu *ekisu = _ekisus[(NSUInteger) [indexPath row]];
    [cell.ekisuThumbnailImageView setImageWithURL:[NSURL URLWithString:ekisu.thumbnail] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [cell.ekisuTitleLabel setText:ekisu.title];

    [cell.indexLabel setText:ekisu.index];
    [cell.shareButton setTag:[indexPath row]];  // set tag of button to indexPath row.
    [cell.shareButton addTarget:self action:@selector(shareEkisu:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)shareEkisu:(UIButton *)sender {
    Ekisu *ekisu =_ekisus[(NSUInteger) sender.tag];
    NSLog(@"%@", ekisu);

    ABDKakaoActivity *kakaoActivity = [[ABDKakaoActivity alloc] init];
    NSString *texttoshare = [NSString stringWithFormat:@"%@ %@, %@", ekisu.index, ekisu.title, ekisu.shareLink];
    NSURL *url = [NSURL URLWithString:ekisu.thumbnail];
    NSArray *activityItems = @[texttoshare, url];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[kakaoActivity]];
    activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeAddToReadingList];
    [self presentViewController:activityVC animated:YES completion:nil];
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

- (NSIndexPath *)indexPathForCurrentPlaying {
    // 현재 재생 중인 플레이어의 indexPath를 반환.
    for (int i=0; i< [_ekisus count]; i++) {
        if ([[_ekisus[i] ekisuId] isEqualToString:_playerViewController.ekisu.ekisuId]) {
           return [NSIndexPath indexPathForRow:i inSection:0];
        }
    }
    return [NSIndexPath indexPathForRow:0 inSection:0];
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