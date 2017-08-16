//
//  main.m
//  Runtime
//
//  Created by NM on 2017/7/5.
//  Copyright © 2017年 huangsunyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NSArray *BNRHierarchyForClass(Class cls) {
    NSMutableArray * classHierarchy = [NSMutableArray array];
    
    for (Class c = cls; c != Nil; c = class_getSuperclass(c)) {
        NSString * className = NSStringFromClass(c);
        [classHierarchy insertObject:className atIndex:0];
    }
    
    return classHierarchy;
}

NSArray * BNRMEthodsForClass(Class cls) {
    
    NSMutableArray * runtimeClassInfo = [NSMutableArray array];
    
    unsigned int methodCount = 0;
    Method * methodList = class_copyMethodList(cls, &methodCount);
    NSMutableArray * methodArray = [NSMutableArray array];
    
    for (int m = 0; m < methodCount; m++) {
        Method currentMethod = methodList[m];
        SEL methodSelector = method_getName(currentMethod);
        [methodArray addObject:NSStringFromSelector(methodSelector)];
    }
    
    return methodArray;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSMutableArray * runtimeClassInfo = [NSMutableArray array];
        
        unsigned int classCount = 0;
        
        Class * classList = objc_copyClassList(&classCount);
        for (int i = 0; i < classCount; i++) {
            Class currentClass = classList[i];
            NSString * className = NSStringFromClass(currentClass);
            
            NSArray * hierarchy = BNRHierarchyForClass(currentClass);
            NSArray * methods = BNRMEthodsForClass(currentClass);
            
            NSDictionary * classInfoDict = @{@"classname": className,
                                             @"hierarchy": hierarchy,
                                             @"methods": methods};
            [runtimeClassInfo addObject:classInfoDict];
        }
        
        free(classList);
        
        NSSortDescriptor * alphaAsc = [NSSortDescriptor     sortDescriptorWithKey:@"className"
                                                                    ascending:YES];
        NSArray * sortedArray = [runtimeClassInfo sortedArrayUsingDescriptors:@[alphaAsc]];
        
        NSLog(@"%@", sortedArray);
        
        
    }
    return 0;
}
