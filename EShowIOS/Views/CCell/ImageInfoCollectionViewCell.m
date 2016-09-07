//
//  ImageInfoCollectionViewCell.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/5.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "ImageInfoCollectionViewCell.h"
#import "UIImageView+WebCache.h"
@implementation ImageInfoCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    UIImageView *imageView = [UIImageView new];
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    self.backgroundColor = [UIColor orangeColor];
}

- (void)setItem:(ImageInfoModel *)item
{
    _item = item;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:item.thumbnail_pic] placeholderImage:[UIImage imageNamed:@"IMG_0094.jpg"]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
}

@end
