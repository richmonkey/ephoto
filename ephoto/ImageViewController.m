//
//  ImageViewController.m
//  ephoto
//
//  Created by houxh on 14-11-25.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "ImageViewController.h"
#import "UIAlertView+XPAlertView.h"


@interface ImageViewController ()
@property(nonatomic, weak)UIImageView *imageView;
@property(nonatomic)UIStatusBarStyle prevStatusStyle;
@end

@implementation ImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.prevStatusStyle = [[UIApplication sharedApplication] statusBarStyle];
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
    [self.view addGestureRecognizer:tap];
    
    if (self.fileInfo) {
        
        UIButton *favButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        [favButton setImage:[UIImage imageNamed:@"topnav_del.png"] forState:UIControlStateNormal];
        [favButton addTarget:self action:@selector(removeAction:)
            forControlEvents:UIControlEventTouchUpInside];
        
        [favButton setTintColor:[UIColor blueColor]];
        UIBarButtonItem *button = [[UIBarButtonItem alloc]
                                   initWithCustomView:favButton];
        
        self.navigationItem.rightBarButtonItem = button;
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
    
    //should add this value to plist: "View controller-based status bar appearance"
    //and set it to "NO".
    [[UIApplication sharedApplication] setStatusBarHidden:isShow withAnimation:UIStatusBarAnimationSlide];
}



-(void)removeAction:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"will delete the image!"  delegate:nil cancelButtonTitle:@"canel" otherButtonTitles:@"ok", nil] ;
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex){
        
        if (buttonIndex == 1) {
            DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
            
            NSError *error;
            bool isComplete =  [filesystem deletePath:self.fileInfo.path error:&error];
            
            if (isComplete) {
                NSLog(@"%@---delete ok!",self.fileInfo.path.stringValue);
            }else{
                NSLog(@"%@",error);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            
        }
    }];;
    

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
