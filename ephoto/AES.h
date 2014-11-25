//
//  AES.h
//  ephoto
//
//  Created by houxh on 14-11-25.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AES : NSObject
+(NSData*)encrypt:(NSData*)data password:(NSString*)password;
+(NSData*)descrypt:(NSData*)data password:(NSString*)password;
@end
