//
//  CloudSelectorViewController.h
//  ephoto
//
//  Created by houxh on 14-11-26.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudSelectorViewController : UITableViewController
@property(nonatomic)NSArray *imageArray;
@property(nonatomic)NSCache *cache;
@end
