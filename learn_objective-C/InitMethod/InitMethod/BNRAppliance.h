//
//  BNRAppliance.h
//  InitMethod
//
//  Created by NM on 2017/7/5.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRAppliance : NSObject
@property (nonatomic, copy) NSString * productName;
@property (nonatomic) int voltage;

- (instancetype)initWithProductName: (NSString *)pn
                         andVoltage: (int) vol;
@end
