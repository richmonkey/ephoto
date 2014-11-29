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
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGRect bounds = self.view.bounds;
    
    //图片居中显示,保持原有宽高比例
    float x, y, w, h;
    if (self.image.size.height/self.image.size.width > bounds.size.height/bounds.size.width) {
        w = bounds.size.height*(self.image.size.width/self.image.size.height);
        h = bounds.size.width;
        x = (bounds.size.width-w)/2;
        y = 0;
        
    } else {
        h = bounds.size.width*(self.image.size.height/self.image.size.width);
        w = bounds.size.width;
        x = 0;
        y = (bounds.size.height-h)/2;
    }
    CGRect frame = CGRectMake(x, y, w, h);
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:frame];
    [self.view addSubview:view];
    self.imageView = view;
    
    self.imageView.image = self.image;
    
    [self.imageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapImageView:)];
    [tap setNumberOfTouchesRequired: 1];
    [self.imageView addGestureRecognizer:tap];
    
    if (self.fileInfo) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"remove"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(removeAction:)];
        self.navigationItem.rightBarButtonItem = item;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTapImageView:(id)sender{
    bool isShow = !self.navigationController.navigationBar.isHidden;
    [self.navigationController.navigationBar setHidden:isShow];
}

-(void)removeAction:(id)sender{
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    
    NSError *error;
    bool isComplete =  [filesystem deletePath:self.fileInfo.path error:&error];
    
    if (isComplete) {
        NSLog(@"%@---delete ok!",self.fileInfo.path.stringValue);
    }else{
        NSLog(@"%@",error);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
