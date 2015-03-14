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

@interface ViewController : GAITrackedViewController <UITableViewDelegate, UITableViewDataSource, EAIntroDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *ekisus;
@end

