//
//  ItemStore.m
//  Homepwner
//
//  Created by NM on 2017/7/7.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "ItemStore.h"
#import "Item.h"

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
        _privateItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *) allItems {
    return [self.privateItems copy];
}

- (Item *) createItem {
    Item * item = [Item randomItem];
    [self.privateItems addObject:item];
    return item;
}

@end
