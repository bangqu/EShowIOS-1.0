//
//  WYJAddressPicker.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/10.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void(^AdressBlock)(NSString *province, NSString *city, NSString *district);

@interface WYJAddressPicker : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic,copy) AdressBlock block;

+ (id)shareInstance;
- (void)showBottomView;
@end
