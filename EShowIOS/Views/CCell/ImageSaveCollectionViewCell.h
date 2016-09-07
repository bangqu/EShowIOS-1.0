//
//  ImageSaveCollectionViewCell.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/3.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageSaveCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) id asset;

- (UIView *)snapshotView;
@end
