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

-(NSArray*)getCloudPhotoList {
    NSMutableArray *photos = [NSMutableArray array];
    LevelDB *db = [LevelDB defaultLevelDB];
    LevelDBIterator *iter = [db newIterator];
    [iter seek:@"cloud_"];
    while (iter.isValid) {
        NSString *key = iter.key;
        if (![key hasPrefix:@"cloud_"]) {
            break;
        }
        NSString *url = [key substringFromIndex:6];
        [photos addObject:url];
        [iter next];
    }
    return photos;
}

-(NSArray*)getLocalPhotoList {
    NSMutableArray *photos = [NSMutableArray array];
    LevelDB *db = [LevelDB defaultLevelDB];
    LevelDBIterator *iter = [db newIterator];
    [iter seek:@"local_url_"];
    while (iter.isValid) {
        NSString *key = iter.key;
        if (![key hasPrefix:@"local_url_"]) {
            break;
        }
        NSString *url = [key substringFromIndex:10];
        [photos addObject:url];
        [iter next];
    }
    return photos;
}

-(NSString*)localKey:(NSString*)url {
    return [NSString stringWithFormat:@"local_url_%@", url];
}

-(NSString*)localCloudPathKey:(NSString*)cloudPath {
    return [NSString stringWithFormat:@"local_cloud_%@", cloudPath];
}

-(NSString*)cloudKey:(NSString*)cloudPath {
    return [NSString stringWithFormat:@"cloud_%@", cloudPath];
}

-(void)addLocalPhoto:(NSString*)url cloudPath:(NSString*)cloudPath {
    LevelDB *db = [LevelDB defaultLevelDB];
    [db setString:cloudPath forKey:[self localKey:url]];
    [db setString:url forKey:[self localCloudPathKey:cloudPath]];
}

-(void)removeLocalPhoto:(NSString*)url {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *cloudPath = [db stringForKey:[self localKey:url]];
    if (cloudPath.length > 0) {
        [db removeValueForKey:[self localCloudPathKey:cloudPath]];
        [db removeValueForKey:[self localKey:url]];
    }
}

-(void)addCloudPhoto:(NSString*)cloudPath {
    LevelDB *db = [LevelDB defaultLevelDB];
    [db setString:@"0" forKey:[self cloudKey:cloudPath]];
}

-(void)removeCloudPhoto:(NSString*)cloudPath {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *url = [db stringForKey:[self cloudKey:cloudPath]];
    if (url.length > 0) {
        [db removeValueForKey:[self cloudKey:cloudPath]];
    }
}

-(BOOL)isExistInCloud:(NSString*)url {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *cloudPath = [db stringForKey:[self localKey:url]];
    if (cloudPath.length == 0) {
        return NO;
    }
    NSString *v = [db stringForKey:[self cloudKey:cloudPath]];
    return v.length > 0;
}

-(BOOL)isExistInLocal:(NSString*)cloudPath {
    LevelDB *db = [LevelDB defaultLevelDB];
    NSString *v = [db stringForKey:[self localCloudPathKey:cloudPath]];
    return v.length > 0;
}

@end
