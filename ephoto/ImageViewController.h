//
//  ImageViewController.h
//  ephoto
//
//  Created by houxh on 14-11-25.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface ImageViewController : UIViewController
@property(nonatomic)UIImage *image;
@property(nonatomic)DBFileInfo  *fileInfo;
@end
