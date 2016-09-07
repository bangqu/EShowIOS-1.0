//
//  NewTaskViewController.h
//  EShowIOS
//
//  Created by MacBook on 16/8/16.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ClearBlock)(NSInteger index);
@interface NewTaskViewController : UIViewController
@property(nonatomic,strong)NSMutableArray *messageArr;
@property(nonatomic,copy)ClearBlock clearBlock;
@end
