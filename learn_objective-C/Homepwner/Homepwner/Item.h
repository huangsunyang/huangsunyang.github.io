//
//  Item.h
//  Homepwner
//
//  Created by NM on 2017/7/7.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject <NSCoding>
{
    NSString *_itemName;
    NSString *_serialNumber;
    int _valueInDollars;
    NSDate *_dateCreated;
}

@property (nonatomic, copy) NSString * imageKey;

+ (instancetype)randomItem;

// Designated initializer for Item
- (instancetype)initWithItemName:(NSString *)name
                  valueInDollars:(int)value
                    serialNumber:(NSString *)sNumber;

- (instancetype)initWithItemName:(NSString *)name;

- (void)setItemName:(NSString *)str;
- (NSString *)itemName;

- (void)setSerialNumber:(NSString *)str;
- (NSString *)serialNumber;

- (void)setValueInDollars:(int)v;
- (int)valueInDollars;

- (NSDate *)dateCreated;

@end
