//
//  ImageViewController.m
//  ephoto
//
//  Created by houxh on 14-11-25.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
@property(nonatomic, weak)UIImageView *imageView;
@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *view = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    self.imageView = view;
    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
