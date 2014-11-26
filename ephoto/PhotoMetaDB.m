//
//  PhotoMetaDB.m
//  ephoto
//
//  Created by houxh on 14-11-26.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "PhotoMetaDB.h"
#import "LevelDB.h"
@implementation PhotoMetaDB
+(PhotoMetaDB*)instance {
    static PhotoMetaDB *db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!db) {
            db = [[PhotoMetaDB alloc] init];
        }
    });
    return db;
}

-(NSArray*)getPhotoList {
    NSMutableArray *photos = [NSMutableArray array];
    LevelDB *db = [LevelDB defaultLevelDB];
    LevelDBIterator *iter = [db newIterator];
    [iter seek:@"local_"];
    while (iter.isValid) {
        NSString *key = iter.key;
        if (![key hasPrefix:@"local_"]) {
            break;
        }
        NSString *url = [key substringFromIndex:6];
        [photos addObject:url];
        [iter next];
    }
    return photos;
}

-(NSString*)localKey:(NSString*)url {
    return [NSString stringWithFormat:@"local_%@", url];
}

-(NSString*)cloudKey:(NSString*)cloudPath {
    return [NSString stringWithFormat:@"cloud_%@", cloudPath];
}

-(void)addPhoto:(NSString*)url cloudPath:(NSString*)cloudPath {
    LevelDB *db = [LevelDB defaultLevelDB];
    [db setString:cloudPath forKey:[self localKey:url]];
    [db setString:url forKey:[self cloudKey:cloudPath]];
}

-(void)removeCloudPhoto:(NSString*)cloudPath {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *url = [db stringForKey:[self cloudKey:cloudPath]];
    if (url.length > 0) {
        [db removeValueForKey:[self cloudKey:cloudPath]];
        [db removeValueForKey:[self localKey:url]];
    }
}

-(void)removeLocalPhoto:(NSString*)url {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *cloudPath = [db stringForKey:[self localKey:url]];
    if (cloudPath.length > 0) {
        [db removeValueForKey:[self cloudKey:cloudPath]];
        [db removeValueForKey:[self localKey:url]];
    }
}

-(BOOL)isExistInCloud:(NSString*)url {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *v = [db stringForKey:[self localKey:url]];
    return v.length > 0;
}

-(BOOL)isExistInLocal:(NSString*)cloudPath {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *v = [db stringForKey:[self cloudKey:cloudPath]];
    return v.length > 0;
}

@end
