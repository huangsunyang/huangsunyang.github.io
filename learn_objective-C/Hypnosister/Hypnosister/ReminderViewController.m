//
//  ReminderViewController.m
//  Hypnosister
//
//  Created by NM on 2017/7/6.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "ReminderViewController.h"
#import <UserNotifications/UserNotifications.h>

@implementation ReminderViewController

- (IBAction)addReminder:(id)sender {
    NSDate * date = self.datePicker.date;
    NSLog(@"Setting a reminder for %@", date);
    
    UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"request authorization succeed");
        }
    }
    ];
    
    UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"title" arguments:nil];
    content.subtitle = [NSString localizedUserNotificationStringForKey:@"subtitle" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"body" arguments:nil];
    
    
    
    UNTimeIntervalNotificationTrigger * trigger = [UNTimeIntervalNotificationTrigger
                                                   triggerWithTimeInterval:10 repeats:NO];
    
    UNNotificationRequest * note = [UNNotificationRequest requestWithIdentifier:@"Hypnotiza me"
                                                                         content:content
                                                                        trigger:trigger];
    
    
    
    [center addNotificationRequest:note withCompletionHandler:^(NSError * _Nullable error){NSLog(@"Completed");}];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Reminder loaded");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:60];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (instancetype) initWithNibName:(NSString *)nibNameOrNil
                          bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        UITabBarItem * tbi = self.tabBarItem;
        tbi.title = @"Reminder";
        UIImage *i = [UIImage imageNamed:@"Time.png"];
        tbi.image = i;
    }
    return self;
}



@end
