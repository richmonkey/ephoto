//
//  CloudImageViewController.m
//  ephoto
//
//  Created by houxh on 15-1-19.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import "CloudImageViewController.h"
#import "UIAlertView+XPAlertView.h"
#import "EPhoto.h"

@interface CloudImageViewController ()


@end

@implementation CloudImageViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)imageCount {
    return self.imageArray.count;
}

-(UIImage*)loadImage:(NSInteger)index {
    if (index < 0 || index >= [self.imageArray count]) {
        return nil;
    }
    
    DBFileInfo *info = [self.imageArray objectAtIndex:index];
    UIImage *image = [EPhoto loadImage:info];
    if (!image) {
        NSLog(@"can't load image from cache");
        return nil;
    }
    return image;
}

-(void)removeImage:(NSInteger)index {
    if (index < 0 || index >= self.imageArray.count) {
        return;
    }
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    DBFileInfo *fileInfo = [self.imageArray objectAtIndex:index];
    NSError *error;
    BOOL isComplete =  [filesystem deletePath:fileInfo.path error:&error];
    if (isComplete) {
        NSLog(@"%@---delete ok!", fileInfo.path.stringValue);
    }else{
        NSLog(@"delete error:%@",error);
    }
    
    [self.imageArray removeObjectAtIndex:index];
}

-(BOOL)removable {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
