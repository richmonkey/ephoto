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


@property(nonatomic)UIImage *prevImage;
@property(nonatomic)UIImage *currentImage;
@property(nonatomic)UIImage *nextImage;

@property(nonatomic, weak)UIImageView *prevImageView;
@property(nonatomic, weak)UIImageView *currentImageView;
@property(nonatomic, weak)UIImageView *nextImageView;

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
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    scrollView.pagingEnabled = YES;
    scrollView.bounces = YES;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    if (self.imageCount == 0 || self.index < 0 || self.index >= self.imageCount) {
        return;
    }
    
    self.prevImage = [self loadImage:self.index - 1];
    self.currentImage = [self loadImage:self.index];
    self.nextImage = [self loadImage:self.index + 1];
    
    if (self.imageCount == 1) {
        CGRect frame = bounds;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        self.currentImageView = imageView;
        self.currentImageView.image = self.currentImage;
        [scrollView addSubview:self.currentImageView];
        scrollView.contentSize = CGSizeMake(bounds.size.width, bounds.size.height);
    } else if (self.imageCount == 2) {
        if (self.prevImage) {
            CGRect frame;
            UIImageView *imageView;
            frame = bounds;
            imageView = [[UIImageView alloc] initWithFrame:frame];
            self.prevImageView = imageView;
            self.prevImageView.image = self.prevImage;
            [scrollView addSubview:self.prevImageView];
            frame = CGRectOffset(bounds, 320, 0);;
            imageView = [[UIImageView alloc] initWithFrame:frame];
            self.currentImageView = imageView;
            self.currentImageView.image = self.currentImage;
            [scrollView addSubview:self.currentImageView];
            scrollView.contentSize = CGSizeMake(bounds.size.width*2, bounds.size.height);
            scrollView.contentOffset = CGPointMake(bounds.size.width, 0);
        } else {
            CGRect frame;
            UIImageView *imageView;
            frame = bounds;
            imageView = [[UIImageView alloc] initWithFrame:frame];
            self.currentImageView = imageView;
            self.currentImageView.image = self.currentImage;
            [scrollView addSubview:self.currentImageView];
            
            frame = CGRectOffset(bounds, 640, 0);
            imageView = [[UIImageView alloc] initWithFrame:frame];
            self.nextImageView = imageView;
            self.nextImageView.image = self.nextImage;
            [scrollView addSubview:self.nextImageView];
            
            scrollView.contentSize = CGSizeMake(bounds.size.width*2, bounds.size.height);
        }
    } else {
        CGRect frame;
        UIImageView *imageView;
        
        if (self.index == 0) {
            self.index = 1;
            self.prevImage = self.currentImage;
            self.currentImage = self.nextImage;
            self.nextImage = [self loadImage:self.index + 1];
            scrollView.contentOffset = CGPointMake(0, 0);
        } else if (self.index == self.imageCount - 1) {
            self.index = self.imageCount - 2;
            self.nextImage = self.currentImage;
            self.currentImage = self.prevImage;
            self.prevImage = [self loadImage:self.index - 1];
            scrollView.contentOffset = CGPointMake(bounds.size.width*2, 0);
        } else {
            scrollView.contentOffset = CGPointMake(bounds.size.width, 0);
        }
        
        frame = bounds;
        imageView = [[UIImageView alloc] initWithFrame:frame];
        self.prevImageView = imageView;
        self.prevImageView.image = self.prevImage;
        [scrollView addSubview:self.prevImageView];
        
        frame = CGRectOffset(bounds, 320, 0);
        imageView = [[UIImageView alloc] initWithFrame:frame];
        self.currentImageView = imageView;
        self.currentImageView.image = self.currentImage;
        [scrollView addSubview:self.currentImageView];
        
        frame = CGRectOffset(bounds, 640, 0);
        imageView = [[UIImageView alloc] initWithFrame:frame];
        self.nextImageView = imageView;
        self.nextImageView.image = self.nextImage;
        [scrollView addSubview:self.nextImageView];
        scrollView.contentSize = CGSizeMake(bounds.size.width*3, bounds.size.height);
    }
    
    self.contentOffset = scrollView.contentOffset;
    
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapImageView:)];
    [tap setNumberOfTouchesRequired: 1];
    [self.view addGestureRecognizer:tap];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGRect bounds = self.view.bounds;
    
    CGPoint offset = scrollView.contentOffset;
    if (offset.x > self.contentOffset.x) {
        self.index = self.index + 1;
    } else if (offset.x < self.contentOffset.x) {
        self.index = self.index - 1;
    }
    self.contentOffset = offset;
    
    if (offset.x == bounds.size.width*2) {
        if (self.index == self.imageCount - 1 || self.index == self.imageCount - 2) {
            return;
        }
        self.index = self.index + 1;
        
        if (self.index >= self.imageCount) {
            return;
        }
        
        self.prevImage = self.currentImage;
        self.currentImage = self.nextImage;
        
        self.nextImage = [self loadImage:self.index + 1];
        
        self.prevImageView.image = self.prevImage;
        self.currentImageView.image = self.currentImage;
        self.nextImageView.image = self.nextImage;
        
    } else if (offset.x == 0) {
        if (self.index == 0 || self.index == 1) {
            return;
        }
        self.index = self.index - 1;
        
        self.nextImage = self.currentImage;
        self.currentImage = self.prevImage;
        
        self.prevImage = [self loadImage:self.index - 1];
        
        self.prevImageView.image = self.prevImage;
        self.currentImageView.image = self.currentImage;
        self.nextImageView.image = self.nextImage;
        
    }
    scrollView.contentOffset = CGPointMake(bounds.size.width, 0);
    self.contentOffset = scrollView.contentOffset;
}

-(CGRect)centerFrame:(CGRect)bounds image:(UIImage*)image {
    //图片居中显示,保持原有宽高比例
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


@end
