//
//  ImageStore.m
//  Homepwner
//
//  Created by NM on 2017/7/10.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import "ImageStore.h"

@interface ImageStore ()

@property (nonatomic, strong) NSMutableDictionary * dictionary;

@end

@implementation ImageStore

+ (instancetype) sharedStore {
    static ImageStore * sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use + [ImageStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype) initPrivate {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *) imagePathForKey: (NSString *) key {
    NSArray * documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:key];
}

- (void) setImage:(UIImage *)image forKey:(NSString *)key {
    [self.dictionary setObject:image forKey:key];
    
    NSString * imagePath = [self imagePathForKey:key];
    
    NSData * data = UIImageJPEGRepresentation(image, 0.5);
    
    [data writeToFile:imagePath atomically:YES];
}

- (void) deleteImageForKey:(NSString *)key {
    if (!key) {
        return;
    }
    [self.dictionary removeObjectForKey:key];
    
    NSString * imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

- (UIImage *)imageForKey:(NSString *)key {
    UIImage * result = [self.dictionary objectForKey:key];
    
    if (!result) {
        NSString * imagePath = [self imagePathForKey:key];
        result = [UIImage imageWithContentsOfFile:imagePath];
        
        if (result) {
            self.dictionary[key] = result;
        } else {
            NSLog(@"Error: unable to find %@", [self imagePathForKey:key]);
        }
    }
    return result;
}

@end
