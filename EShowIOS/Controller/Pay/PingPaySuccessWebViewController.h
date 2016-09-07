//
//  PingPaySuccessWebViewController.h
//  EShowIOS
//
//  Created by 王迎军 on 16/8/16.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"
@interface PingPaySuccessWebViewController : UIViewController<UIWebViewDelegate,NJKWebViewProgressDelegate>

@property (nonatomic,retain)UIWebView *webView;
@property (nonatomic,strong)NSString *urlString;
@property (nonatomic,strong)NSString *titleString;
@property (nonatomic,strong)NSString *orderType;
@property (nonatomic , strong) NSString *titleName;

@property  int shareId;
@property (readwrite,nonatomic) BOOL hasShare;
@property (readwrite,nonatomic) BOOL needDelay;
@end
