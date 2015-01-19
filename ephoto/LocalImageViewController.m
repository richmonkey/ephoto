//
//  LocalImageViewController.m
//  ephoto
//
//  Created by houxh on 15-1-19.
//  Copyright (c) 2015年 beetle. All rights reserved.
//

#import "LocalImageViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface LocalImageViewController ()

@end

@implementation LocalImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)imageCount {
    return self.assets.count;
}

-(UIImage*)loadImage:(NSInteger)index {
    if (index < 0 || index >= self.assets.count) {
        return nil;
    }
    
    ALAsset *asset = [self.assets objectAtIndex:index];

    ALAssetRepresentation *rep = [asset defaultRepresentation];
    CGImageRef cimage = [[asset defaultRepresentation] fullScreenImage];
//    UIImageOrientation orientation = (UIImageOrientation)[[asset defaultRepresentation] orientation];
//    NSLog(@"orientation:%d", orientation);
    
    //http://stackoverflow.com/questions/8832547/orientation-does-not-behave-correctly-with-photo-in-alasset/9447468#9447468
    UIImage *image = [UIImage imageWithCGImage:cimage scale:rep.scale orientation:UIImageOrientationUp];
    return image;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

