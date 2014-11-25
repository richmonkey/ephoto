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
        self.v1 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v1];
        
        frame = CGRectMake(x+64, y + 68, 16, 12);
        self.i1 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i1];
        x += 80;
        
        frame = CGRectMake(x, y, 80, 80);
        self.v2 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v2];
        
        frame = CGRectMake(x+64, y + 68, 16, 12);
        self.i2 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i2];
        x += 80;
        
        frame = CGRectMake(x, y, 80, 80);
        self.v3 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v3];
        
        frame = CGRectMake(x+64, y + 68, 16, 12);
        self.i3 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i3];
        x += 80;
        
        frame = CGRectMake(x, y, 80, 80);
        self.v4 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v4];
        
        frame = CGRectMake(x+64, y + 68, 16, 12);
        self.i4 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i4];
        x += 80;
    }
    return self;
}
@end

