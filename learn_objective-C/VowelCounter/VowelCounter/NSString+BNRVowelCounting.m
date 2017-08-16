//
//  NSString+BNRVowelCounting.m
//  VowelCounter
//
//  Created by NM on 2017/7/5.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "NSString+BNRVowelCounting.h"

@implementation NSString (BNRVowelCounting)

- (int)bnr_vowelCount {
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"aeiouAEIOUY"];
    
    NSUInteger count = [self length];
    int sum = 0;
    for (int i = 0; i < count; i++) {
        unichar c = [self characterAtIndex:i];
        if ([charSet characterIsMember:c]) {
            sum++;
        }
    }
    return sum;
}

@end
