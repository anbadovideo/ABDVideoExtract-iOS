//
//  AppDelegate.m
//  ABDVideoExtract
//
//  Created by Seung-won Kim on 1/27/15.
//  Copyright (c) 2015 anbado video. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _serverURL = @"https://stormy-crag-2618.herokuapp.com";

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Push Notification Methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 파일에 토큰 저장.
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                    ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                    ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                    ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    NSLog(@"My token is: %@\n%@", deviceToken, hexToken);

    NSDictionary *parameters = @{
            @"type" : @"ios",
            @"token" : hexToken,
    };

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:[NSString stringWithFormat:@"%@/devices/", _serverURL] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode != 400) {
            // 400 에러는 중복된 데이터 등록 시에 발생이므로 예외
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register error"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"NO"
                                                      otherButtonTitles:@"Retry", nil];
            [alertView show];
        }
    }];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier
        forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    [self application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@, %@", error, [error userInfo]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification: called! message: %@", userInfo);
}

@end
