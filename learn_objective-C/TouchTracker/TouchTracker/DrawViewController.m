//
//  DrawViewController.m
//  TouchTracker
//
//  Created by NM on 2017/7/10.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "DrawViewController.h"
#import "DrawView.h"

@implementation DrawViewController

# pragma mark - Life Cycle

- (void) loadView {
    self.view = [[DrawView alloc] initWithFrame:CGRectZero];
}

@end
