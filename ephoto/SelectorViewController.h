//
//  SelectorViewController.h
//  ephoto
//
//  Created by houxh on 14-11-25.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SelectorViewController : UITableViewController
@property(nonatomic) NSArray *assets;
@property(nonatomic) ALAssetsLibrary *library;
@end
