//
//  CloudImageViewController.h
//  ephoto
//
//  Created by houxh on 15-1-19.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface CloudImageViewController : UIViewController
@property(nonatomic)UIImage *image;
@property(nonatomic)DBFileInfo  *fileInfo;
@end
