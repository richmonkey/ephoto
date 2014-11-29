//
//  FirstViewController.m
//  ephoto
//
//  Created by houxh on 14-11-24.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "LocalViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import <Dropbox/Dropbox.h>
#import "ImageTableViewCell.h"
#import "SelectorViewController.h"
#import "ImageViewController.h"
#import "PhotoMetaDB.h"
#import "EPhoto.h"


@interface LocalViewController ()
@property(nonatomic)ALAssetsLibrary *library;
@property(nonatomic)NSArray *assets;
@end

@implementation LocalViewController
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(copyToCloud)];
    self.navigationItem.rightBarButtonItem = item;


    [self listImages];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAssetChangedNotifiation:)
                                                 name:ALAssetsLibraryChangedNotification object:nil];
    NSLog(@"local view");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handleAssetChangedNotifiation:(NSNotification *)notification
{
    NSLog(@"notification: %@", notification);
    
    [self listImages];
    
}
-(void)copyToCloud {
    NSLog(@"copy to cloud");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SelectorViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Selector"];
    controller.assets = self.assets;
    controller.library = self.library;
    [self.navigationController pushViewController:controller animated:YES];
}



- (void)listImages {
    
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
            self.assets = assets;
            self.library = library;
            
            PhotoMetaDB *db = [PhotoMetaDB instance];
            NSArray *photos = [db getLocalPhotoList];
            NSLog(@"local photos:%@", photos);
            NSMutableSet *set = [NSMutableSet setWithArray:photos];
            for (ALAsset *asset in self.assets) {
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
            [self.tableView reloadData];
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"A problem occurred");}];
    
}

-(void)onClick:(UIButton*)sender {
    NSLog(@"tag:%d", sender.tag);
    int index = sender.tag;
    if (index >= [self.assets count]) {
        return;
    }
    ALAsset *asset = [self.assets objectAtIndex:index];

    CGImageRef cimage = [[asset defaultRepresentation] fullResolutionImage];
    UIImageOrientation orientation = (UIImageOrientation)[[asset defaultRepresentation] orientation];
    NSLog(@"orientation:%d", orientation);
    
    UIImage *image = [UIImage imageWithCGImage:cimage scale:1.0 orientation:orientation];
    
    ImageViewController *c = [[ImageViewController alloc] init];
    c.image = image;
    c.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:c animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.assets count]/4 + ([self.assets count]%4?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageTableViewCell *cell = (ImageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell.v1 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.v2 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.v3 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.v4 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    int index = indexPath.row*4;
    if (index < [self.assets count]) {
        ALAsset *asset = [self.assets objectAtIndex:index];
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
        [cell.v1 setImage:i forState:UIControlStateNormal];
        cell.v1.tag = index;
        cell.v1.hidden = NO;
    } else {
        cell.v1.hidden = YES;
    }
    
    index++;
    if (index < [self.assets count]) {
        ALAsset *asset = [self.assets objectAtIndex:index];
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
        [cell.v2 setImage:i forState:UIControlStateNormal];
        cell.v2.tag = index;
        cell.v2.hidden = NO;
    } else {
        cell.v2.hidden = YES;
    }
    
    index++;
    if (index < [self.assets count]) {
        ALAsset *asset = [self.assets objectAtIndex:index];
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
        [cell.v3 setImage:i forState:UIControlStateNormal];
        cell.v3.tag = index;
        cell.v3.hidden = NO;
    } else {
        cell.v3.hidden = YES;
    }
    
    index++;
    if (index < [self.assets count]) {
        ALAsset *asset = [self.assets objectAtIndex:index];
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
        [cell.v4 setImage:i forState:UIControlStateNormal];
        cell.v4.tag = index;
        cell.v4.hidden = NO;
    } else {
        cell.v4.hidden = YES;
    }
    return cell;
}

@end
