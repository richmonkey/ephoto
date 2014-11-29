//
//  EPhoto.m
//  ephoto
//
//  Created by houxh on 14-11-28.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "EPhoto.h"

#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"
#import "SecretKey.h"

#import <CommonCrypto/CommonDigest.h>


@implementation EPhoto
+(NSData*)encrypt:(NSData*)data password:(NSString*)password {
    NSData *encryptedData = [data AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return encryptedData;
}

+(NSData*)descrypt:(NSData*)data password:(NSString*)password {
    NSData *decryptedData = [data decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return decryptedData;
}

+(NSString *)md5:(NSData *)data {
    unsigned char digest[16];
    CC_MD5( [data bytes], [data length], digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

+(DBPath*)imageRootPath {
    SecretKey *key = [SecretKey instance];
    const char *p = [key.key UTF8String];
    NSString *path = [self md5:[NSData dataWithBytes:p length:strlen(p)]];
    return [[DBPath root] childPath:path];
}

+(DBPath*)imageCloudPath:(ALAssetRepresentation*)rep {
    int size = (int)[rep size];
    NSMutableData *data = [NSMutableData dataWithLength:size];
    
    void *p = [data mutableBytes];
    NSError *error;
    int r = [rep getBytes:p fromOffset:0 length:size error:&error];
    if (r == 0) {
        NSLog(@"byte zero:%@ size:%d", error, size);
        return nil;
    }
    
    NSString *md5 = [self md5:data];
    DBPath *path = [self imageRootPath];
    path = [path childPath:md5];
    return path;
}

+(UIImage*)loadImage:(DBFileInfo*)info {
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    DBFile *file = [filesystem openFile:info.path error:nil];
    if (file == nil) {
        NSLog(@"open file error");
        return nil;
    }
    if (!file.status.cached) {
        NSLog(@"file is't in cache");
        return nil;
    }
    NSData *data = [file readData:nil];
    if (data == nil) {
        NSLog(@"read file error");
        return nil;
    }
    
    SecretKey *key = [SecretKey instance];
    NSData *ddata = [self descrypt:data password:key.key];
    UIImage *image = [UIImage imageWithData:ddata];
    if (image == nil) {
        NSLog(@"invalid file format");
        return nil;
    }
    
    return image;
}

+(void)copyFile:(ALAsset*)asset {
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    int size = (int)[rep size];
    NSMutableData *data = [NSMutableData dataWithLength:size];
    
    void *p = [data mutableBytes];
    NSError *error;
    int r = [rep getBytes:p fromOffset:0 length:size error:&error];
    if (r == 0) {
        NSLog(@"byte zero:%@ size:%d", error, size);
        return;
    }
    
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    NSString *md5 = [self md5:data];
    DBPath *path = [self imageRootPath];
    path = [path childPath:md5];
    
    SecretKey *key = [SecretKey instance];
    NSData *edata = [self encrypt:data password:key.key];
    
    DBFile *file;
    DBError *err;
    DBFileInfo *info = [filesystem fileInfoForPath:path error:&err];
    if (info) {
        if (info.size == [edata length]) {
            NSLog(@"file exist:%@", [path stringValue]);
            return;
        } else {
            file = [filesystem openFile:path error:&err];
            if (!file) {
                NSLog(@"open file error:%@", err);
                return;
            }
            NSLog(@"open old file:%@", path.stringValue);
        }
    } else {
        file = [filesystem createFile:path error:&err];
        if (!file) {
            NSLog(@"create file error:%@", err);
            return;
        }
        NSLog(@"create file:%@", path.stringValue);
    }
    
    BOOL res = [file writeData:edata error:nil];
    if (!res) {
        NSLog(@"write file error");
        return;
    }
    
    [file close];
}

@end
