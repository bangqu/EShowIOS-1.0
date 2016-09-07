//
//  ChatViewController.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/31.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ContectViewController;
@protocol ChooseContectDelegate <NSObject>
-(void)addressPicker:(ContectViewController *)contect didSelectedCity:(NSString*)city;

- (void)beginSearch:(UISearchBar*)searchBar;

- (void)endSearch:(UISearchBar*)searchBar;

@end
@interface ContectViewController : UIViewController
@property (nonatomic, weak) id <ChooseContectDelegate> delegate;
@end
