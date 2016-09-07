//
//  ImageLiatCollectionViewCell.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/2.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "ImageListCollectionViewCell.h"
#import "UIImageView+WebCache.h"
@interface ImageListCollectionViewCell ()
{
    UIImageView *coverImg;
    UILabel  *titleLable;
    UIImageView *genderImg;
    UILabel *nickLable;
    UIImageView *audienceImg;
    UILabel    *audienceLable;
}
@end
@implementation ImageListCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if  (!self )  return nil;
    // self.backgroundColor =  [UIColor redColor];
    [self setup];
    return self;
}
- (void)setup
{
    UIImageView *imageView = [[UIImageView alloc] init];
    //    imageView.backgroundColor = [UIColor grayColor];
    [self.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.and.right.equalTo(self);
    }];
    UILabel *titleLabel = [UILabel new];
    [imageView addSubview:titleLabel];
    titleLabel.backgroundColor = [UIColor blackColor];
    titleLabel.alpha = 0.6;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(imageView.mas_bottom);
        make.left.equalTo(imageView.mas_left);
        make.right.equalTo(imageView.mas_right);
        make.height.mas_equalTo(@30);
    }];
    titleLabel.font = [UIFont systemFontOfSize:16];
    self.image = imageView;
    self.title = titleLabel;

}
- (void)setContentWith:(ImageListModel *)model
{
    _model = model;
//    [self.image setImage:[UIImage imageNamed:@"Newimage"]];
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.image_icon] placeholderImage:[UIImage imageNamed:@"IMG_0094.jpg"]];
    self.title.text = model.image_title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.image.frame = self.bounds;
}
@end
