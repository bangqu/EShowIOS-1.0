//
//  ImageLiatCollectionViewCell.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/2.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageListModel.h"
@interface ImageListCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) ImageListModel *model;
-(void)setContentWith:(ImageListModel *)model;
@end
