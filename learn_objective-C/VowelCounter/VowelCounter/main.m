//
//  main.m
//  VowelCounter
//
//  Created by NM on 2017/7/5.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+BNRVowelCounting.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        NSString * string = @"Hello world";
        NSLog(@"%@ has %d vowels", string, string.bnr_vowelCount);
    }
    return 0;
}
