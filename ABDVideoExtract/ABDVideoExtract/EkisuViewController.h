//
//  ViewController.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/27/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EAIntroView/EAIntroView.h>
#import "GAITrackedViewController.h"
#import "SlideNavigationController.h"

@interface EkisuViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, EAIntroDelegate, SlideNavigationControllerDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *ekisus;
@property (nonatomic, strong) NSString *categoryTitle;

- (void)refreshData;
@end

