//
//  ViewController.h
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/27/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *ekisus;
@end

