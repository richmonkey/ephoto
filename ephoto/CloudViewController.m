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
#import "SecretKey.h"
#import "CloudImageViewController.h"
#import "CloudSelectorViewController.h"
#import "PhotoMetaDB.h"
#import "EPhoto.h"

@interface CloudViewController ()
@property(nonatomic)NSArray *imageArray;
@property(nonatomic)NSArray *pendingImages;
@property(nonatomic)NSCache *cache;
@property(nonatomic)NSTimer *statusTimer;
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
    NSLog(@"cloudviewcontroller did load");
    DBAccountManager *manager = [DBAccountManager sharedManager];
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
    NSLog(@"cloudviewcontroller did loaded");
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(copyToLocal)];
    self.navigationItem.rightBarButtonItem = item;
    

    self.statusTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refreshStatus) userInfo:nil repeats:YES];
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

+(BOOL)isPending:(DBFile*)file {
    if (file.status && (file.status.state == DBFileStateDownloading || file.status.state == DBFileStateUploading)) {
        return YES;
    } else if(file.newerStatus && (file.newerStatus.state == DBFileStateDownloading || file.newerStatus.state == DBFileStateUploading)) {
        return YES;
    }
    return NO;
}


-(void)refreshStatus {
    NSLog(@"refresh status");
    NSMutableArray *pendingImages = [NSMutableArray array];
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    for (DBFileInfo *info in self.imageArray) {
        DBFile *file = [filesystem openFile:info.path error:nil];
        if (file == nil) {
            NSLog(@"open file error");
            continue;
        }
        if ([CloudViewController isPending:file]) {
            [pendingImages addObject:info];
        }
        [file close];
    }
    
    self.pendingImages = pendingImages;
    [self.tableView reloadData];
}

-(void)onClick:(UIButton*)sender {
    NSLog(@"tag:%zd", sender.tag);
    NSInteger index = sender.tag;
    if (index >= [self.imageArray count]) {
        return;
    }
    
    DBFileInfo *info = [self.imageArray objectAtIndex:index];
    UIImage *image = [EPhoto loadImage:info];
    if (!image) {
        NSLog(@"can't load image from cache");
        return;
    }
    CloudImageViewController *c = [[CloudImageViewController alloc] init];
    c.image = image;
    c.fileInfo = info;
    c.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:c animated:YES];
}

- (UIImage*)loadImage:(DBFileInfo*)info {
    UIImage *image = [self.cache objectForKey:info.path.stringValue];
    
    if (image != nil) {
        return image;
    }
    image = [EPhoto loadImage:info];
    if (image == nil) {
        return nil;
    }
    
    UIImage *sizeImage = [image resizedImage:CGSizeMake(128, 128) interpolationQuality:kCGInterpolationDefault];
    [self.cache setObject:sizeImage forKey:info.path.stringValue];
    
    return sizeImage;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
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
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger index = indexPath.row*4;
    if (index < [self.imageArray count]) {
        DBFileInfo *info = [self.imageArray objectAtIndex:index];
        UIImage *image = [self loadImage:info];
        if (!image) {
            NSLog(@"can't load image from cache");
        }
        [cell.v1 setImage:image forState:UIControlStateNormal];
        cell.v1.tag = index;
        cell.v1.hidden = NO;
        if ([self.pendingImages containsObject:info]) {
            [cell.a1 startAnimating];
        } else if (cell.a1.isAnimating) {
            [cell.a1 stopAnimating];
        }
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
        if ([self.pendingImages containsObject:info]) {
            [cell.a2 startAnimating];
        } else if (cell.a1.isAnimating) {
            [cell.a2 stopAnimating];
        }
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
        if ([self.pendingImages containsObject:info]) {
            [cell.a3 startAnimating];
        } else if (cell.a1.isAnimating) {
            [cell.a3 stopAnimating];
        }
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
        if ([self.pendingImages containsObject:info]) {
            [cell.a4 startAnimating];
        } else if (cell.a1.isAnimating) {
            [cell.a4 stopAnimating];
        }
    } else {
        cell.v4.hidden = YES;
    }
    return cell;
}

-(void)setupFS:(DBAccount*)account {
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    DBPath *newPath = [EPhoto imageRootPath];
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
    DBPath *newPath = [EPhoto imageRootPath];
    DBFilesystem *filesystem = [DBFilesystem sharedFilesystem];
    DBError *error;
    NSArray *array = [filesystem listFolder:newPath error:&error];
    if (!array) {
        NSLog(@"list folder error");
        return;
    }

    PhotoMetaDB *db = [PhotoMetaDB instance];
    NSArray *photos = [db getCloudPhotoList];
    NSLog(@"cloud photos:%@", photos);
    NSMutableSet *set = [NSMutableSet setWithArray:photos];
    for (DBFileInfo *info in array) {
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
    NSLog(@"listed cloud image");
    
    //在后台完成读取数据后，刷新界面
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"load cloud image");
        for (DBFileInfo *info in array) {
            @autoreleasepool {
                DBFile *file = [filesystem openFile:info.path error:nil];
                if (file == nil) {
                    NSLog(@"open file error");
                    continue;
                }
                if (file.status.cached) {
                    continue;
                }
                //waiting readed from cloud
                [file readData:nil];
                [file close];
            }
        }
        NSLog(@"loaded cloud image");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageArray = array;
            [self refreshStatus];
            [self.tableView reloadData];
        });
    });
    
}
@end
