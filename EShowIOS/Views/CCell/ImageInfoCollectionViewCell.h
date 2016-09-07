//
//  ImageInfoCollectionViewCell.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/5.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageInfoModel.h"
@interface ImageInfoCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, strong) ImageInfoModel *item;
@end
