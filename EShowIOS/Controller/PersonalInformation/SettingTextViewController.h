//
//  SettingTextViewController.h
//  EShowIOS
//
//  Created by 金璟 on 16/3/29.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTextViewController : UIViewController
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSString *setData;
@property (strong, nonatomic) NSString *dataType;       //判断数据是什么属性
@end
