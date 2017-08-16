//
//  main.m
//  InitMethod
//
//  Created by NM on 2017/7/5.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNRAppliance.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        BNRAppliance * b = [BNRAppliance alloc];
        [b setValue:@"werw" forKey:@"productName"];
        [b setValue:[NSNumber numberWithInt:123] forKey:@"voltage"];
        NSLog(@"Name is %@, voltage is %d", b.productName, b.voltage);
    }
    return 0;
}
