//
//  LoginViewController.m
//  ephoto
//
//  Created by houxh on 14-11-24.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "LoginViewController.h"
#import <Dropbox/Dropbox.h>
#import "SecretKey.h"
#import "MainTabBarController.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoMetaDB.h"
#import "EPhoto.h"
#import "MBProgressHUD.h"
#import "SecretViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *dropboxButton;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property(nonatomic) DBAccount *account;
@end

@implementation LoginViewController

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
    
    CALayer *imageLayer = [self.backView layer];   //获取ImageView的层
    [imageLayer setMasksToBounds:YES];
    [imageLayer setCornerRadius: 5];
    
    [self.backView setBackgroundColor:RGBACOLOR(15, 15, 15, 0.6)];
    
    DBAccountManager *manager = [DBAccountManager sharedManager];
    DBAccount *account = [manager linkedAccount];
    SecretKey *sk = [SecretKey instance];
    if (account.isLinked && [sk.key length] > 0) {
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
        [DBFilesystem setSharedFilesystem:filesystem];
        
        NSLog(@"account:%@ name:%@ key:%@", account.info.displayName, account.info.userName, sk.key);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainTabBarController *main = [storyboard instantiateViewControllerWithIdentifier:@"Main"];
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        delegate.window.rootViewController = main;
        return;
    }
    if (account && account.isLinked) {
        if ([account.info.displayName length] > 0) {
            [self.dropboxButton setTitle:account.info.displayName forState:UIControlStateNormal];
            [self.dropboxButton setTitle:account.info.displayName forState:UIControlStateDisabled];
        }
        self.dropboxButton.enabled = NO;
       [self showNextButton];
        self.account = account;
        
        __weak LoginViewController *wself = self;
        [self.account addObserver:self block:^{
            if (wself.account.isLinked && [wself.account.info.displayName length] > 0) {
                [wself.dropboxButton setTitle:account.info.displayName forState:UIControlStateNormal];
                [wself.dropboxButton setTitle:account.info.displayName forState:UIControlStateDisabled];
            }
        }];
    }


    __weak LoginViewController *wself = self;
    [manager addObserver:self block:^(DBAccount* account) {
        NSLog(@"account changed:%@", account.info.displayName);
        if (account && account.isLinked) {
            if ([account.info.displayName length] > 0) {
                [wself.dropboxButton setTitle:account.info.displayName forState:UIControlStateNormal];
                [wself.dropboxButton setTitle:account.info.displayName forState:UIControlStateDisabled];
            }
            [self showNextButton];
            wself.dropboxButton.enabled = NO;
            
            if (wself.account != account) {
                [wself.account removeObserver:self];
                wself.account = account;
                [wself.account addObserver:wself block:^{
                    if (wself.account.isLinked && [wself.account.info.displayName length] > 0) {
                        NSLog(@"account name:%@", account.info.displayName);
                        [wself.dropboxButton setTitle:account.info.displayName forState:UIControlStateNormal];
                        [wself.dropboxButton setTitle:account.info.displayName forState:UIControlStateDisabled];
                    }
                }];
            }
        }
    }];
    

    

}

- (IBAction)linkDropbox:(id)sender {
    DBAccountManager *manager = [DBAccountManager sharedManager];
    DBAccount *account = [manager linkedAccount];
    if (!account) {
        [manager linkFromController:self];
    }
}

- (IBAction)nextAction:(id)sender{
    DBAccountManager *manager = [DBAccountManager sharedManager];
    DBAccount *account = [manager linkedAccount];
    if (!account) {
        NSLog(@"no account linked");
        return;
    }
    
    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
    [DBFilesystem setSharedFilesystem:filesystem];
 
    
    [manager removeObserver:self];
    [self.account removeObserver:self];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SecretViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Secret"];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)showNextButton{
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(nextAction:)];
    
    self.navigationItem.rightBarButtonItem = item;
    
}


@end
