//
//  SelectorViewController.m
//  ephoto
//
//  Created by houxh on 14-11-25.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "SelectorViewController.h"
#import "ImageTableViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import "LevelDB.h"
#import <Dropbox/Dropbox.h>
#import "SecretKey.h"
#import "PhotoMetaDB.h"
#import "EPhoto.h"

@interface SelImage : NSObject

@property(nonatomic)ALAsset *asset;
@property(nonatomic, assign)BOOL selected;
@end

@implementation SelImage

@end

@interface SelectorViewController ()
@property(nonatomic) NSArray *images;
@end

@implementation SelectorViewController

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
                                                            target:self action:@selector(copyToCloud)];
    self.navigationItem.rightBarButtonItem = item;
    PhotoMetaDB *db = [PhotoMetaDB instance];
    NSMutableArray *images = [NSMutableArray array];
    for (ALAsset *asset in self.assets) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        NSLog(@"filename:%@ url:%@, uti:%@", [rep filename], [rep url], [rep UTI]);
        if ([db isExistInCloud:rep.url.absoluteString]) {
            continue;
        }
        SelImage *s = [[SelImage alloc] init];
        s.asset = asset;
        [images addObject:s];
    }
    self.images = images;
}

-(void)copyToCloud {
    for (SelImage *image in self.images) {
        if (image.selected) {
            [EPhoto copyFile:image.asset];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onClick:(UIButton*)sender {
    NSLog(@"tag:%d", sender.tag);
    SelImage *simage = [self.images objectAtIndex:sender.tag];
    simage.selected = !simage.selected;
    
    int row = sender.tag/4;
    NSIndexPath *p = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:p] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.images count]/4 + ([self.images count]%4?1:0);
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
        SelImage *s = [self.images objectAtIndex:index];
        ALAsset *asset = s.asset;
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
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
        SelImage *s = [self.images objectAtIndex:index];
        ALAsset *asset = s.asset;
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
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
        SelImage *s = [self.images objectAtIndex:index];
        ALAsset *asset = s.asset;
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
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
        SelImage *s = [self.images objectAtIndex:index];
        ALAsset *asset = s.asset;
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
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
