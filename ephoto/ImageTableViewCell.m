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
        float y = 1;
        CGRect frame;
        frame = CGRectMake(x, y, 78, 80);
        self.v1 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v1];
        
        frame = CGRectMake(x+29, y+30, 20, 20);
        self.a1 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.a1 setFrame: frame];
        [self addSubview:self.a1];
        
        frame = CGRectMake(x+62, y + 68, 16, 12);
        self.i1 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i1];
        x += 80;
        
        frame = CGRectMake(x, y, 79, 80);
        self.v2 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v2];
        
        frame = CGRectMake(x+29, y+30, 20, 20);
        self.a2 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.a2 setFrame: frame];
        [self addSubview:self.a2];
        
        frame = CGRectMake(x+63, y + 68, 16, 12);
        self.i2 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i2];
        x += 81;
        
        frame = CGRectMake(x, y, 79, 80);
        self.v3 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v3];
        
        frame = CGRectMake(x+29, y+30, 20, 20);
        self.a3 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.a3 setFrame: frame];
        [self addSubview:self.a3];
        
        frame = CGRectMake(x+63, y + 68, 16, 12);
        self.i3 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i3];
        x += 81;
        
        frame = CGRectMake(x, y, 78, 80);
        self.v4 = [[UIButton alloc] initWithFrame:frame];
        [self addSubview:self.v4];
        
        frame = CGRectMake(x+29, y+30, 20, 20);
        self.a4 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.a4 setFrame: frame];
        [self addSubview:self.a4];
        
        frame = CGRectMake(x+62, y + 68, 16, 12);
        self.i4 = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:self.i4];
        x += 80;
    }
    return self;
}
@end

