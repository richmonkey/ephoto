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
#import "ImageTableViewCell.h"

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
	// Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self listImages];
    NSLog(@"local view");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            self.library = library;
            self.assets = assets;
            [self.tableView reloadData];
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"A problem occurred");}];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.assets count]/4 + ([self.assets count]%4?1:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageTableViewCell *cell = (ImageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    int index = indexPath.row*4;
    if (index < [self.assets count]) {
        ALAsset *asset = [self.assets objectAtIndex:index];
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
        cell.v1.image = i;
    }
    
    index++;
    if (index < [self.assets count]) {
        ALAsset *asset = [self.assets objectAtIndex:index];
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
        cell.v2.image = i;
    }
    
    index++;
    if (index < [self.assets count]) {
        ALAsset *asset = [self.assets objectAtIndex:index];
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
        cell.v3.image = i;
    }

    
    index++;
    if (index < [self.assets count]) {
        ALAsset *asset = [self.assets objectAtIndex:index];
        UIImage *i = [UIImage imageWithCGImage:[asset thumbnail]];
        cell.v4.image = i;
    }

    
    return cell;
}

@end
