//
//  SecretKey.m
//  ephoto
//
//  Created by houxh on 14-11-24.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "SecretKey.h"

@implementation SecretKey
+(SecretKey*)instance {
    static SecretKey *key = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!key) {
            key = [[SecretKey alloc] init];
        }
    });
    return key;
}

-(NSString*)keyPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/secret.key", documentsDirectory];
}
-(void)save {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.key forKey:@"key"];
    [dict writeToFile:[self keyPath] atomically:YES];
}

-(void)load {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self keyPath]];
    self.key = [dict objectForKey:@"key"];
}
@end
