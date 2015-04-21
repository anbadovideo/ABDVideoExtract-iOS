//
//  TeamSelectViewController.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 4/13/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "MenuTableViewController.h"
#import "SlideNavigationController.h"
#import "EkisuViewController.h"

const static int kLions     = 0;
const static int kHeroes    = 1;
const static int kDinos     = 2;
const static int kTwins     = 3;
const static int kWyverns   = 4;
const static int kBears     = 5;
const static int kGiants    = 6;
const static int kTigers    = 7;
const static int kEagles    = 8;
const static int kWiz       = 9;

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    EkisuViewController *ekisuViewController = (EkisuViewController *)[storyboard instantiateViewControllerWithIdentifier:@"EkisuViewController"];

    if ([indexPath section] == 0) {
        /* team select menu */
        NSString *categoryFullTitle = [NSString new];
        NSString *categoryTitle = [NSString new];
        switch ([indexPath row]) {
            case kLions:
                categoryTitle = @"lions";
                categoryFullTitle = @"삼성라이온스";
                break;
            case kHeroes:
                categoryTitle = @"heroes";
                categoryFullTitle = @"넥센히어로즈";
                break;
            case kDinos:
                categoryTitle = @"dinos";
                categoryFullTitle = @"NC다이노스";
                break;
            case kTwins:
                categoryTitle = @"twins";
                categoryFullTitle = @"LG트윈스";
                break;
            case kWyverns:
                categoryTitle = @"wyverns";
                categoryFullTitle = @"SK와이번스";
                break;
            case kBears:
                categoryTitle = @"bears";
                categoryFullTitle = @"두산베어스";
                break;
            case kGiants:
                categoryTitle = @"giants";
                categoryFullTitle = @"롯데자이언츠";
                break;
            case kTigers:
                categoryTitle = @"tigers";
                categoryFullTitle = @"기아타이거즈";
                break;
            case kEagles:
                categoryTitle = @"eagles";
                categoryFullTitle = @"한화이글스";
                break;
            case kWiz:
                categoryTitle = @"wiz";
                categoryFullTitle = @"kt위즈";
                break;
            default:
                break;
        }
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:ekisuViewController
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:^{
                                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshTable" object:nil userInfo:@{@"category__title": categoryTitle, @"category__fullTitle": categoryFullTitle}];
                                                                         }];
    } else {
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:ekisuViewController
                                                                 withSlideOutAnimation:YES
                                                                         andCompletion:^{
                                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"SendMail" object:nil userInfo:nil];
                                                                         }];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
