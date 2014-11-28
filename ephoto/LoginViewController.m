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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *dropboxButton;
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
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


- (void)listImages:(void (^)())completed {
    NSMutableArray* assets = [[NSMutableArray alloc] init];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
            [assets addObject:result];
        }
    };
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
        } else {
            PhotoMetaDB *db = [PhotoMetaDB instance];
            NSArray *photos = [db getLocalPhotoList];
            NSLog(@"local photos:%@", photos);
            NSMutableSet *set = [NSMutableSet setWithArray:photos];
            for (ALAsset *asset in assets) {
                @autoreleasepool {
                    ALAssetRepresentation *rep = [asset defaultRepresentation];
                    if ([set containsObject:rep.url.absoluteString]) {
                        [set removeObject:rep.url.absoluteString];
                    } else {
                        DBPath *path = [EPhoto imageCloudPath:rep];
                        [db addLocalPhoto:rep.url.absoluteString cloudPath:path.stringValue];
                        NSLog(@"add local photo url:%@ cloud path:%@", rep.url.absoluteString, path.stringValue);
                    }
                }
            }
            for (NSString *url in set) {
                NSLog(@"remove local photo:%@", url);
                [db removeLocalPhoto:url];
            }
            NSLog(@"local image loaded");
            completed();
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {
                             NSLog(@"A problem occurred");
                             completed();
                         }];
    
}
- (IBAction)confirm:(id)sender {
    if ([self.keyTextField.text length] < 6) {
        return;
    }
    
    DBAccountManager *manager = [DBAccountManager sharedManager];
    DBAccount *account = [manager linkedAccount];
    if (!account || !account.isLinked) {
        NSLog(@"no account linked");
        return;
    }
    
    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
    [DBFilesystem setSharedFilesystem:filesystem];
    
    [SecretKey instance].key = self.keyTextField.text;
    [[SecretKey instance] save];

    [manager removeObserver:self];
    [self.account removeObserver:self];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self listImages:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MainTabBarController *main = [storyboard instantiateViewControllerWithIdentifier:@"Main"];
                AppDelegate *delegate = [UIApplication sharedApplication].delegate;
                delegate.window.rootViewController = main;
            });
        }];
    });
}

- (IBAction)linkDropbox:(id)sender {
    DBAccountManager *manager = [DBAccountManager sharedManager];
    DBAccount *account = [manager linkedAccount];
    if (!account) {
        [manager linkFromController:self];
    }
}

@end
