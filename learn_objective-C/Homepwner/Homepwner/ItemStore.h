//
//  ItemStore.h
//  Homepwner
//
//  Created by NM on 2017/7/7.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Item;

@interface ItemStore : NSObject

@property (nonatomic, readonly) NSArray * allItems;

+ (instancetype) sharedStore;
- (Item *) createItem;
- (void) removeItem: (Item *) item;
- (void) moveItemAtIndex: (NSUInteger) fromIndex
                 toIndex: (NSUInteger) toIndex;
- (BOOL) saveChanges;
@end
