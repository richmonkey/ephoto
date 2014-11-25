//
//  SecondViewController.m
//  ephoto
//
//  Created by houxh on 14-11-24.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "CloudViewController.h"
#import <Dropbox/Dropbox.h>
#import "ImageTableViewCell.h"
#import "UIImage+Resize.h"

@interface CloudViewController ()
@property(nonatomic)NSMutableDictionary *imageDict;
@property(nonatomic)NSArray *imageArray;
@property(nonatomic)NSCache *cache;
@end

@implementation CloudViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageDict = [NSMutableDictionary dictionary];
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    DBAccountManager *manager = [DBAccountManager sharedManager];
    [manager addObserver:self block:^(DBAccount *account) {
        NSLog(@"account changed:%@", account);
        if (account) {
            [self setupFS:account];
            if ([DBFilesystem sharedFilesystem].completedFirstSync) {
                [self listImages];
            }
        }
    }];
    DBAccount *account = [manager linkedAccount];
    
    if (account) {
        [self setupFS:account];
        if ([DBFilesystem sharedFilesystem].completedFirstSync) {
            [self listImages];
        }
    } else {
        NSLog(@"account unlinked");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.imageArray count]/4 + ([self.imageArray count]%4?1:0);
}

- (UIImage*)loadImage:(DBFileInfo*)info {
    UIImage *image = [self.cache objectForKey:info.path.stringValue];
    
    if (image != nil) {
        return image;
    }
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
    
    image = [UIImage imageWithData:data];
    if (image == nil) {
        NSLog(@"invalid file format");
        return nil;
    }
    
    UIImage *sizeImage = [image resizedImage:CGSizeMake(128, 128) interpolationQuality:kCGInterpolationDefault];
    [self.cache setObject:sizeImage forKey:info.path.stringValue];
    return sizeImage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageTableViewCell *cell = (ImageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[ImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    int index = indexPath.row*4;
    if (index < [self.imageArray count]) {
        DBFileInfo *info = [self.imageArray objectAtIndex:index];
        cell.v1.image = [self loadImage:info];
    }
    
    index++;
    if (index < [self.imageArray count]) {
        DBFileInfo *info = [self.imageArray objectAtIndex:index];
        cell.v2.image = [self loadImage:info];
    }
    
    index++;
    if (index < [self.imageArray count]) {
        DBFileInfo *info = [self.imageArray objectAtIndex:index];
        cell.v3.image = [self loadImage:info];
    }
    
    index++;
    if (index < [self.imageArray count]) {
        DBFileInfo *info = [self.imageArray objectAtIndex:index];
        cell.v4.image = [self loadImage:info];
    }
    return nil;
}

-(void)setupFS:(DBAccount*)account {
    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
    [DBFilesystem setSharedFilesystem:filesystem];

    DBPath *newPath = [[DBPath root] childPath:@"images"];
    DBFileInfo *info = [filesystem fileInfoForPath:newPath error:nil];
    if (info == nil) {
        BOOL r = [filesystem createFolder:newPath error:nil];
        if (!r) {
            NSLog(@"create folder error");
            return;
        }
        NSLog(@"create images folder successfully!");
    }

    [filesystem addObserver:self forPathAndChildren:newPath block:^{
        NSLog(@"filesystem changed");
        [self listImages];
    }];
}

-(void)listImages {
    DBPath *newPath = [[DBPath root] childPath:@"images"];
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    DBError *error;
    NSArray *array = [filesystem listFolder:newPath error:&error];
    if (!array) {
        NSLog(@"list folder error");
        return;
    }
    
    NSMutableSet *removedSet = [NSMutableSet setWithArray:[self.imageDict allKeys]];
    for (DBFileInfo *info in array) {
        DBFileInfo *oldInfo = [self.imageDict objectForKey:info.path.stringValue];
        if (!oldInfo) {
            [self.imageDict setObject:info forKey:info.path.stringValue];
            NSLog(@"file %@ added", info.path.stringValue);
        } else if (![info.modifiedTime isEqualToDate:oldInfo.modifiedTime]) {
            [self.imageDict setObject:info forKey:info.path.stringValue];
            NSLog(@"file %@ updated", info.path.stringValue);
        } else {
            NSLog(@"file %@ unchanged", info.path.stringValue);
        }
        [removedSet removeObject:info.path.stringValue];
    }

    //removed
    for (NSString *key in removedSet) {
        [self.imageDict removeObjectForKey:key];
        NSLog(@"file %@ removed", key);
    }
    self.imageArray = [self.imageDict allValues];
    [self.tableView reloadData];
    
}
@end
