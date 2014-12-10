//
//  SecretViewController.m
//  ephoto
//
//  Created by 杨朋亮 on 27/11/14.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "SecretViewController.h"

#import "SecretViewController.h"
#import <Dropbox/Dropbox.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "EPhoto.h"
#import "PhotoMetaDB.h"
#import "SecretKey.h"
#import "MainTabBarController.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"

@interface SecretViewController ()
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@end

@implementation SecretViewController

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
    
    self.keyTextField.delegate = self;
    [self.keyTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.saveButton setEnabled:NO];
    [self.saveButton setBackgroundColor:RGBCOLOR(100, 100, 100)];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture addTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapGesture];
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

    [SecretKey instance].key = self.keyTextField.text;
    [[SecretKey instance] save];
    
    [self.keyTextField resignFirstResponder];
    
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

#pragma mark - UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:NO];
}

- (void)animateTextField:(BOOL)up
{
    const int movementDistance = 80;
    const float movementDuration = 0.3f;
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    
    [UIView setAnimationBeginsFromCurrentState: YES];
    
    [UIView setAnimationDuration: movementDuration];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            self.view.frame = CGRectOffset(self.view.frame, movement , 0);
        }else{
            self.view.frame = CGRectOffset(self.view.frame, -movement , 0);
        }
    }else{
        if (orientation == UIInterfaceOrientationPortrait) {
            self.view.frame = CGRectOffset(self.view.frame, 0 , movement);
        }else{
            self.view.frame = CGRectOffset(self.view.frame, 0 , -movement);
        }
    }
    [UIView commitAnimations];
    
}

-(void)tapAction:(id)sender{
    [self.keyTextField resignFirstResponder];
}

- (void) textFieldDidChange:(id) sender {
    UITextField *_field = (UITextField *)sender;
    if ([_field text].length >= 6) {
        [self.saveButton setEnabled:YES];
        [self.saveButton setBackgroundColor:RGBCOLOR(17,124,255)];
    }else{
        [self.saveButton setEnabled:NO];
        [self.saveButton setBackgroundColor:RGBCOLOR(100, 100, 100)];
    }
}

@end
