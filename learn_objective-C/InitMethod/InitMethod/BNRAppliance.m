//
//  BNRAppliance.m
//  InitMethod
//
//  Created by NM on 2017/7/5.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "BNRAppliance.h"

@implementation BNRAppliance

@synthesize productName = _productName;
@synthesize voltage = _voltage;

- (void) setProductName:(NSString *)productName {
    _productName = [productName mutableCopy];
}

- (NSString *) productName {
    return [_productName copy];
}

- (void)setVoltage:(int)voltage {
    NSLog(@"in setVoltage");
    _voltage = voltage;
}

- (int)voltage {
    return _voltage;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _voltage = 120;
    }
    
    return self;
}

- (instancetype)initWithProductName:(NSString *)pn andVoltage:(int)vol {
    self = [super init];
    if (self) {
        _voltage = vol;
        _productName = [pn copy];
    }
    return self;
}

@end
