//
//  PhotoMetaDB.h
//  ephoto
//
//  Created by houxh on 14-11-26.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoMetaDB : NSObject
+(PhotoMetaDB*)instance;

-(NSArray*)getLocalPhotoList;
-(NSArray*)getCloudPhotoList;

-(void)addCloudPhoto:(NSString*)cloudPath;
-(void)removeCloudPhoto:(NSString*)cloudPath;

-(void)addLocalPhoto:(NSString*)url cloudPath:(NSString*)cloudPath;
-(void)removeLocalPhoto:(NSString*)url;

-(BOOL)isExistInCloud:(NSString*)url;
-(BOOL)isExistInLocal:(NSString*)cloudPath;
@end
