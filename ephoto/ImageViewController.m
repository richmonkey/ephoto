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


@property(nonatomic)NSInteger index1;
@property(nonatomic)NSInteger index2;
@property(nonatomic)NSInteger index3;

@property(nonatomic)UIImage *image1;
@property(nonatomic)UIImage *image2;
@property(nonatomic)UIImage *image3;

@property(nonatomic, weak)UIImageView *imageView1;
@property(nonatomic, weak)UIImageView *imageView2;
@property(nonatomic, weak)UIImageView *imageView3;

@property(nonatomic, weak)UIScrollView *scrollView;
@property(nonatomic, assign)CGPoint contentOffset;

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
    bounds.size.width += 20;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    scrollView.pagingEnabled = YES;
    scrollView.bounces = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    [self loadImageViews];
    
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapImageView:)];
    [tap setNumberOfTouchesRequired: 1];
    [self.view addGestureRecognizer:tap];
    
    if (self.removable) {
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

- (void)loadImageViews {
    if (self.imageCount == 0 || self.index < 0 || self.index >= self.imageCount) {
        return;
    }
    
    if (self.index == 0) {
        self.image1 = [self loadImage:self.index];
        self.image2 = [self loadImage:self.index + 1];
        self.image3 = [self loadImage:self.index + 2];
        self.index1 = self.index;
        self.index2 = self.index + 1;
        self.index3 = self.index + 2;
    } else {
        self.image1 = [self loadImage:self.index - 1];
        self.image2 = [self loadImage:self.index];
        self.image3 = [self loadImage:self.index + 1];
        
        self.index1 = self.index - 1;
        self.index2 = self.index;
        self.index3 = self.index + 1;
    }
    

    UIScrollView *scrollView = self.scrollView;
    CGRect bounds = scrollView.bounds;
    CGRect viewBounds = bounds;
    viewBounds.size.width -= 20;
    
    CGRect frame;
    UIImageView *imageView;
    
    frame = viewBounds;
    imageView = [[UIImageView alloc] initWithFrame:frame];
    self.imageView1 = imageView;
    self.imageView1.image = self.image1;
    [scrollView addSubview:self.imageView1];
    
    frame = CGRectOffset(viewBounds, bounds.size.width, 0);
    imageView = [[UIImageView alloc] initWithFrame:frame];
    self.imageView2 = imageView;
    self.imageView2.image = self.image2;
    [scrollView addSubview:self.imageView2];
    
    frame = CGRectOffset(viewBounds, bounds.size.width*2, 0);
    imageView = [[UIImageView alloc] initWithFrame:frame];
    self.imageView3 = imageView;
    self.imageView3.image = self.image3;
    [scrollView addSubview:self.imageView3];
    
    
    if (self.imageCount == 1) {
        scrollView.contentSize = CGSizeMake(bounds.size.width, bounds.size.height);
        scrollView.contentOffset = CGPointMake(0, 0);
    } else if (self.imageCount == 2) {
        scrollView.contentSize = CGSizeMake(bounds.size.width*2, bounds.size.height);
        if (self.index == 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
        } else {
            scrollView.contentOffset = CGPointMake(bounds.size.width, 0);
        }
    } else {
        scrollView.contentSize = CGSizeMake(bounds.size.width*3, bounds.size.height);
        if (self.index == 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
        } else if (self.index == self.imageCount - 1) {
            scrollView.contentOffset = CGPointMake(bounds.size.width*2, 0);
        } else {
            scrollView.contentOffset = CGPointMake(bounds.size.width, 0);
        }
    }
    
    self.contentOffset = scrollView.contentOffset;

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    CGRect bounds = scrollView.bounds;
    
    CGPoint offset = scrollView.contentOffset;

    if (offset.x > self.contentOffset.x && (offset.x - self.contentOffset.x) > bounds.size.width/2) {
        if (self.index == self.imageCount - 1) {
            self.contentOffset = offset;
            return;
        }
        
        self.index = self.index + 1;
        if (self.index == self.imageCount - 1) {
            self.contentOffset = offset;
            return;
        }
        if (self.index == self.index2) {
            self.contentOffset = offset;
            return;
        }
        
        self.index1 = self.index2;
        self.index2 = self.index3;
        self.index3 = self.index3 + 1;
        
        self.image1 = self.image2;
        self.image2 = self.image3;
        self.image3 = [self loadImage:self.index3];
        
        self.imageView1.image = self.image1;
        self.imageView2.image = self.image2;
        self.imageView3.image = self.image3;
        
        scrollView.contentOffset = CGPointMake(bounds.size.width, 0);
        self.contentOffset = scrollView.contentOffset;
        
        
    } else if (offset.x < self.contentOffset.x && (self.contentOffset.x - offset.x) > bounds.size.width/2) {
        if (self.index == 0) {
            self.contentOffset = offset;
            return;
        }
        
        self.index = self.index - 1;
        if (self.index == 0) {
            self.contentOffset = offset;
            return;
        }
        
        if (self.index == self.index2) {
            self.contentOffset = offset;
            return;
        }
        
        self.index3 = self.index2;
        self.index2 = self.index1;
        self.index1 = self.index1 - 1;
        
        self.image3 = self.image2;
        self.image2 = self.image1;
        self.image1 =[self loadImage:self.index1];
        
        self.imageView1.image = self.image1;
        self.imageView2.image = self.image2;
        self.imageView3.image = self.image3;
        
        scrollView.contentOffset = CGPointMake(bounds.size.width, 0);
        self.contentOffset = scrollView.contentOffset;
        
    }
}

-(CGRect)centerFrame:(CGRect)bounds image:(UIImage*)image {
    //图片居中显示,保持原有宽高比例
    if (image.size.width == 0 || bounds.size.width == 0) {
        return CGRectMake(0, 0, 0, 0);
    }
    float x, y, w, h;
    if (image.size.height/image.size.width > bounds.size.height/bounds.size.width) {
        w = bounds.size.height*(image.size.width/image.size.height);
        h = bounds.size.width;
        x = bounds.origin.x + (bounds.size.width-w)/2;
        y = bounds.origin.y;
        
    } else {
        h = bounds.size.width*(image.size.height/image.size.width);
        w = bounds.size.width;
        x = bounds.origin.x;
        y = bounds.origin.y + (bounds.size.height-h)/2;
    }
    return CGRectMake(x, y, w, h);
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

-(NSInteger)imageCount {
    return 0;
}

-(UIImage*)loadImage:(NSInteger)index {
    return nil;
}

-(BOOL)removable {
    return NO;
}

-(void)removeImage:(NSInteger)index {
    
}

-(void)removeAction:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"will delete the image!"  delegate:nil cancelButtonTitle:@"canel" otherButtonTitles:@"ok", nil] ;
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex){
        if (buttonIndex == 1) {
            [self removeImage:self.index];
            if (self.index > 0) {
                self.index = self.index - 1;
            }
            [self.imageView1 removeFromSuperview];
            [self.imageView2 removeFromSuperview];
            [self.imageView3 removeFromSuperview];
            self.imageView1 = nil;
            self.imageView2 = nil;
            self.imageView3 = nil;
            [self loadImageViews];
        }
    }];
    
    
}


@end
