//
//  ImageStore.h
//  Homepwner
//
//  Created by NM on 2017/7/10.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageStore : NSObject

+ (instancetype) sharedStore;
- (void) setImage: (UIImage *) image forKey: (NSString *) key;
- (UIImage *) imageForKey: (NSString *) key;
- (void) deleteImageForKey: (NSString *) key;
@end
