//
//  SecretKey.h
//  ephoto
//
//  Created by houxh on 14-11-24.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecretKey : NSObject
@property(nonatomic,copy)NSString *key;

+(SecretKey*)instance;

-(void)save;
-(void)load;
@end
