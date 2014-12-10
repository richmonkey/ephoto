//
//  ImageTableViewCell.m
//  ephoto
//
//  Created by houxh on 14-11-24.
//  Copyright (c) 2014年 beetle. All rights reserved.
//

#import "ImageTableViewCell.h"

#define KCellWidth          80
#define CellImageWidth      80
#define CellImageHeight     78
#define KCellImageXOffset   1.0
#define kCellImageYOffset   2.0
#define kMarkWidth      16
#define kMarkHeight     12
#define kMarkXOffset    64
#define kMarkYOffset    66


@implementation ImageTableViewCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        float x = 0;
        float y = 0;
        CGRect frame;
        frame = CGRectMake(x, y, CellImageWidth - 1, CellImageHeight);
        self.v1 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v1];
        
        frame = CGRectMake(x+kMarkXOffset, y + kMarkYOffset, kMarkWidth, kMarkHeight);
        self.i1 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i1];
        x += KCellWidth + KCellImageXOffset;
        
        frame = CGRectMake(x, y, CellImageWidth - 2, CellImageHeight);
        self.v2 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v2];
        
        frame = CGRectMake(x+kMarkXOffset, y + kMarkYOffset, kMarkWidth, kMarkHeight);
        self.i2 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i2];
        x += KCellWidth + KCellImageXOffset;
        
        frame = CGRectMake(x, y, CellImageWidth - 2, CellImageHeight);
        self.v3 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v3];
        
        frame = CGRectMake(x+kMarkXOffset, y + kMarkYOffset, kMarkWidth, kMarkHeight);
        self.i3 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i3];
        x += KCellWidth + KCellImageXOffset;
        
        frame = CGRectMake(x, y, CellImageWidth - 1, CellImageHeight);
        self.v4 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v4];
        
        frame = CGRectMake(x+kMarkXOffset, y + kMarkYOffset, kMarkWidth, kMarkHeight);
        self.i4 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i4];
        x += KCellWidth + KCellImageXOffset;
    }
    return self;
}
@end

