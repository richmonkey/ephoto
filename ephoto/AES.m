//
//  AES.m
//  ephoto
//
//  Created by houxh on 14-11-25.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "AES.h"

#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"


@implementation AES
+(NSData*)encrypt:(NSData*)data password:(NSString*)password {
    NSData *encryptedData = [data AES256EncryptedDataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return encryptedData;
}

+(NSData*)descrypt:(NSData*)data password:(NSString*)password {
    NSData *decryptedData = [data decryptedAES256DataUsingKey:[[password dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
    return decryptedData;
}
@end
