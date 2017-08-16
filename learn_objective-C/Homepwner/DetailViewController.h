//
//  DetailViewController.h
//  Homepwner
//
//  Created by NM on 2017/7/10.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Item;

@interface DetailViewController : UIViewController
@property (nonatomic, strong) Item * item;
@property (nonatomic, copy) void(^dismissBlock)(void);
- (instancetype) initForNewItem: (BOOL) isNew;
@end
