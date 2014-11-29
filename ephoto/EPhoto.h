//
//  EPhoto.h
//  ephoto
//
//  Created by houxh on 14-11-28.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface EPhoto : NSObject
+(NSData*)encrypt:(NSData*)data password:(NSString*)password;
+(NSData*)descrypt:(NSData*)data password:(NSString*)password;

+(DBPath*)imageCloudPath:(ALAssetRepresentation*)rep;
+(void)copyFile:(ALAsset*)asset;
+(UIImage*)loadImage:(DBFileInfo*)info;
+(DBPath*)imageRootPath;
@end
