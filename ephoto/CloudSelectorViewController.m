//
//  CloudSelectorViewController.m
//  ephoto
//
//  Created by houxh on 14-11-26.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "CloudSelectorViewController.h"
#import "ImageTableViewCell.h"
#import <Dropbox/Dropbox.h>
#import "SecretKey.h"
#import "AES.h"
#import "UIImage+Resize.h"
#import "PhotoMetaDB.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CloudSelImage : NSObject

@property(nonatomic)DBFileInfo *info;
@property(nonatomic, assign)BOOL selected;
@end

@implementation CloudSelImage

@end

@interface CloudSelectorViewController ()
@property(nonatomic)NSArray *images;
@end

@implementation CloudSelectorViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(copyToLocal)];
    self.navigationItem.rightBarButtonItem = item;
    
    PhotoMetaDB *db = [PhotoMetaDB instance];
    NSMutableArray *images = [NSMutableArray array];
    for (DBFileInfo *info in self.imageArray) {
        if ([db isExistInLocal:info.path.stringValue]) {
            continue;
        }
        CloudSelImage *image = [[CloudSelImage alloc] init];
        image.info = info;
        [images addObject:image];
    }
    self.images = images;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)copyToLocal {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    for (CloudSelImage *image in self.images) {
        if (!image.selected) {
            continue;
        }
        UIImage *i = [self loadOriginImage:image.info];
        if (i == nil) {
            continue;
        }
        [library writeImageToSavedPhotosAlbum:[i CGImage]
                                  orientation:(ALAssetOrientation)[i imageOrientation]
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  if (error) {
                                      NSLog(@"save photo error:%@", error);
                                  }
                              }
         ];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onClick:(UIButton*)sender {
    NSLog(@"tag:%d", sender.tag);
    
    CloudSelImage *simage = [self.images objectAtIndex:sender.tag];
    simage.selected = !simage.selected;
    
    int row = sender.tag/4;
    NSIndexPath *p = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:p] withRowAnimation:UITableViewRowAnimationNone];
}

-(UIImage*)loadOriginImage:(DBFileInfo*)info {
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    DBFile *file = [filesystem openFile:info.path error:nil];
    if (file == nil) {
        NSLog(@"open file error");
        return nil;
    }
    NSData *data = [file readData:nil];
    if (data == nil) {
        NSLog(@"read file error");
        return nil;
    }
    
    SecretKey *key = [SecretKey instance];
    NSData *ddata = [AES descrypt:data password:key.key];
    UIImage *image = [UIImage imageWithData:ddata];
    if (image == nil) {
        NSLog(@"invalid file format");
    }
    return image;
}

- (UIImage*)loadImage:(DBFileInfo*)info {
    UIImage *image = [self.cache objectForKey:info.path.stringValue];
    if (image != nil) {
        return image;
    }
    
    image = [self loadOriginImage:info];
    if (image == nil) {
        return nil;
    }
    
    UIImage *sizeImage = [image resizedImage:CGSizeMake(128, 128) interpolationQuality:kCGInterpolationDefault];
    [self.cache setObject:sizeImage forKey:info.path.stringValue];
    return sizeImage;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

   return [self.imageArray count]/4 + ([self.imageArray count]%4?1:0);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageTableViewCell *cell = (ImageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell.v1 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.v2 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.v3 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.v4 addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    int index = indexPath.row*4;
    if (index < [self.images count]) {
        CloudSelImage *s = [self.images objectAtIndex:index];
        DBFileInfo *info = s.info;
        UIImage *i = [self loadImage:info];
        [cell.v1 setImage:i forState:UIControlStateNormal];
        if (s.selected) {
            cell.i1.image = [UIImage imageNamed:@"CheckSingleGreen"];
        } else {
            cell.i1.image = nil;
        }
        cell.v1.tag = index;
        cell.v1.hidden = NO;
        cell.i1.hidden = NO;
    } else {
        cell.v1.hidden = YES;
        cell.i1.hidden = YES;
    }
    
    index++;
    if (index < [self.images count]) {
        CloudSelImage *s = [self.images objectAtIndex:index];
        DBFileInfo *info = s.info;
        UIImage *i = [self loadImage:info];
        [cell.v2 setImage:i forState:UIControlStateNormal];
        if (s.selected) {
            cell.i2.image = [UIImage imageNamed:@"CheckSingleGreen"];
        } else {
            cell.i2.image = nil;
        }
        cell.v2.tag = index;
        cell.v2.hidden = NO;
        cell.i2.hidden = NO;
    } else {
        cell.v2.hidden = YES;
        cell.i2.hidden = YES;
    }
    
    index++;
    if (index < [self.images count]) {
        CloudSelImage *s = [self.images objectAtIndex:index];
        DBFileInfo *info = s.info;
        UIImage *i = [self loadImage:info];
        [cell.v3 setImage:i forState:UIControlStateNormal];
        if (s.selected) {
            cell.i3.image = [UIImage imageNamed:@"CheckSingleGreen"];
        } else {
            cell.i3.image = nil;
        }
        cell.v3.tag = index;
        cell.v3.hidden = NO;
        cell.i3.hidden = NO;
    } else {
        cell.v3.hidden = YES;
        cell.i3.hidden = YES;
    }
    
    index++;
    if (index < [self.images count]) {
        CloudSelImage *s = [self.images objectAtIndex:index];
        DBFileInfo *info = s.info;
        UIImage *i = [self loadImage:info];
        [cell.v4 setImage:i forState:UIControlStateNormal];
        if (s.selected) {
            cell.i4.image = [UIImage imageNamed:@"CheckSingleGreen"];
        } else {
            cell.i4.image = nil;
        }
        cell.v4.tag = index;
        cell.v4.hidden = NO;
        cell.i4.hidden = NO;
    } else {
        cell.v4.hidden = YES;
        cell.i4.hidden = YES;
    }
    
    return cell;
}


@end
