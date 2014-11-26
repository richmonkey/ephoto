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
#import "AES.h"
#import "SecretKey.h"
#import "ImageViewController.h"
#import "CloudSelectorViewController.h"
#import "PhotoMetaDB.h"

@interface CloudViewController ()
@property(nonatomic)NSArray *imageArray;
@property(nonatomic)NSCache *cache;
@end

@implementation CloudViewController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
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
        NSLog(@"linked accout:%@", account);
        if ([DBFilesystem sharedFilesystem].completedFirstSync) {
            [self listImages];
        }
    } else {
        NSLog(@"account unlinked");
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(copyToLocal)];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)copyToLocal {
    NSLog(@"copy to local");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CloudSelectorViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"CloudSelector"];
    controller.imageArray = self.imageArray;
    controller.cache = self.cache;
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)onClick:(UIButton*)sender {
    NSLog(@"tag:%d", sender.tag);
    int index = sender.tag;
    if (index >= [self.imageArray count]) {
        return;
    }
    
    DBFileInfo *info = [self.imageArray objectAtIndex:index];
    UIImage *image = [self loadFullScreenImage:info];
    ImageViewController *c = [[ImageViewController alloc] init];
    c.image = image;
    [self.navigationController pushViewController:c animated:YES];
}

-(UIImage*)loadFullScreenImage:(DBFileInfo*)info {
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
        return nil;
    }
    
    return image;

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
    
    SecretKey *key = [SecretKey instance];
    NSData *ddata = [AES descrypt:data password:key.key];
    image = [UIImage imageWithData:ddata];
    if (image == nil) {
        NSLog(@"invalid file format");
        return nil;
    }
    
    UIImage *sizeImage = [image resizedImage:CGSizeMake(128, 128) interpolationQuality:kCGInterpolationDefault];
    [self.cache setObject:sizeImage forKey:info.path.stringValue];
    return sizeImage;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.imageArray count]/4 + ([self.imageArray count]%4?1:0);
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
    int index = indexPath.row*4;
    if (index < [self.imageArray count]) {
        DBFileInfo *info = [self.imageArray objectAtIndex:index];
        UIImage *image = [self loadImage:info];
        [cell.v1 setImage:image forState:UIControlStateNormal];
        cell.v1.tag = index;
        cell.v1.hidden = NO;
    } else {
        cell.v1.hidden = YES;
    }
    
    index++;
    if (index < [self.imageArray count]) {
        DBFileInfo *info = [self.imageArray objectAtIndex:index];
        UIImage *image = [self loadImage:info];
        [cell.v2 setImage:image forState:UIControlStateNormal];
        cell.v2.tag = index;
        cell.v2.hidden = NO;
    } else {
        cell.v2.hidden = YES;
    }
    
    index++;
    if (index < [self.imageArray count]) {
        DBFileInfo *info = [self.imageArray objectAtIndex:index];
        UIImage *image = [self loadImage:info];
        [cell.v3 setImage:image forState:UIControlStateNormal];
        cell.v3.tag = index;
        cell.v3.hidden = NO;
    } else {
        cell.v3.hidden = YES;
    }
    
    index++;
    if (index < [self.imageArray count]) {
        DBFileInfo *info = [self.imageArray objectAtIndex:index];
        UIImage *image = [self loadImage:info];
        [cell.v4 setImage:image forState:UIControlStateNormal];
        cell.v4.tag = index;
        cell.v4.hidden = NO;
    } else {
        cell.v4.hidden = YES;
    }
    return cell;
}

-(void)setupFS:(DBAccount*)account {
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
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
        if ([DBFilesystem sharedFilesystem].completedFirstSync) {
            [self listImages];
        }
    }];
}

-(void)listImages {
    NSLog(@"list cloud image");
    DBPath *newPath = [[DBPath root] childPath:@"images"];
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    DBError *error;
    NSArray *array = [filesystem listFolder:newPath error:&error];
    if (!array) {
        NSLog(@"list folder error");
        return;
    }
    
    self.imageArray = array;

    PhotoMetaDB *db = [PhotoMetaDB instance];
    NSArray *photos = [db getCloudPhotoList];
    NSLog(@"cloud photos:%@", photos);
    NSMutableSet *set = [NSMutableSet setWithArray:photos];
    for (DBFileInfo *info in self.imageArray) {
        if ([set containsObject:info.path.stringValue]) {
            [set removeObject:info.path.stringValue];
        } else {
            [db addCloudPhoto:info.path.stringValue];
            NSLog(@"cloud photo added:%@", info.path.stringValue);
        }
    }
    //removed
    for (NSString *path in set) {
        [db removeCloudPhoto:path];
        NSLog(@"cloud photo removed:%@", path);
    }
    
    [self.tableView reloadData];
    
}
@end
