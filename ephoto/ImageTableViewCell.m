//
//  ImageTableViewCell.m
//  ephoto
//
//  Created by houxh on 14-11-24.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "ImageTableViewCell.h"


@implementation ImageTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        float x = 0;
        float y = 0;
        CGRect frame;
        frame = CGRectMake(x, y, 80, 80);
        self.v1 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.v1];
        x += 80;
        
        frame = CGRectMake(x, y, 80, 80);
        self.v2 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.v2];
        x += 80;
        
        frame = CGRectMake(x, y, 80, 80);
        self.v3 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.v3];
        x += 80;
        
        frame = CGRectMake(x, y, 80, 80);
        self.v4 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.v4];
        x += 80;
    }
    return self;
}
@end

