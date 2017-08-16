//
//  ItemStore.m
//  Homepwner
//
//  Created by NM on 2017/7/7.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "ItemStore.h"
#import "Item.h"
#import "ImageStore.h"

@interface ItemStore()
@property (nonatomic) NSMutableArray * privateItems;
@end

@implementation ItemStore

+ (instancetype) sharedStore {
    static ItemStore * sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype) init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use + [ItemSotre sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype) initPrivate {
    self = [super init];
    if (self) {
        NSString * path = [self itemAchievePath];
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!_privateItems) {
            _privateItems = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSArray *) allItems {
    return [self.privateItems copy];
}

- (Item *) createItem {
    Item * item = [[Item alloc] init];
    [self.privateItems addObject:item];
    return item;
}

- (void) removeItem:(Item *)item {
    NSString * key = item.imageKey;
    [[ImageStore sharedStore] deleteImageForKey:key];
    [self.privateItems removeObjectIdenticalTo:item];
}

- (void) moveItemAtIndex:(NSUInteger)fromIndex
                 toIndex:(NSUInteger)toIndex {
    if (fromIndex != toIndex) {
        Item * item = self.privateItems[fromIndex];
        if (toIndex < 1) toIndex += 1;
        [self.privateItems removeObjectAtIndex:fromIndex];
        [self.privateItems insertObject:item atIndex:toIndex];
    }
}

- (NSString *)itemAchievePath {
    NSArray * documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}


- (BOOL) saveChanges {
    NSString * path = [self itemAchievePath];
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
}

@end
