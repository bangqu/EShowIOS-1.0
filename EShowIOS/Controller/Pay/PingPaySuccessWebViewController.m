//
//  PingPaySuccessWebViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/16.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "PingPaySuccessWebViewController.h"
#import "NJKWebViewProgressView.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"
@interface PingPaySuccessWebViewController ()
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    int number;
    NSURL *lastUrl;
    UILabel *titleText;
    
    MBProgressHUD *hud;
}
@end

@implementation PingPaySuccessWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.titleString;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1] ;
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    self.webView.delegate = self;
    self.webView.scrollView.bounces = NO;
    [self.view addSubview:self.webView];
    
    // [self setBack];
    [self setLoadingStyle];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 设置延时，单位秒
    double delay = 1.0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queue, ^{
        // 3秒后需要执行的任务
        self.urlString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self.urlString, nil, nil, kCFStringEncodingUTF8));
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
        lastUrl = [NSURL URLWithString:self.urlString];
        
    });
}
-(void) setBack
{
    //标题
    titleText = [[UILabel alloc] initWithFrame: CGRectMake(160, 0, 200, 50)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor = [UIColor colorWithRed:141.0/255.0 green:194.0/255.0 blue:96.0/255.0 alpha:1];
    titleText.textAlignment = 1;
    [titleText setFont:[UIFont boldSystemFontOfSize:18.0]];
}

-(void) setLoadingStyle
{
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.5f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    _progressView.backgroundColor = [UIColor colorWithRed:0.945 green:0.510 blue:0.525 alpha:0.000];
    _progressView.progressBarView.backgroundColor = [UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //h5页面跳转  也要隐藏底部tabbar
    
    
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_progressView removeFromSuperview];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    
    NSString *title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [titleText setText:self.titleString];
    self.navigationItem.titleView = titleText;
    
    if ([title  isEqual: @"兑换成功"]) {
        //左上角加分项按钮
        self.navigationItem.rightBarButtonItem = nil;
        UIButton *shareBar =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [shareBar setTitle:@"分享" forState:UIControlStateNormal];
        shareBar.titleLabel.font = [UIFont systemFontOfSize:15.0];
        
        [shareBar addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *shareBarItem = [[UIBarButtonItem alloc] initWithCustomView:shareBar];
        
        self.navigationItem.rightBarButtonItem = shareBarItem;
    }
    
}
-(void)share{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"url: %@", request.URL.absoluteURL.description);
    //判断是否是单击
//    if (navigationType == UIWebViewNavigationTypeLinkClicked)
//    {
//        if ([[XJUserDefaults objectForKey:@"playBack"] isEqualToString:@"paymentOrder"]) {
//            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
//        }else if([[XJUserDefaults objectForKey:@"playBack"] isEqualToString:@"serveOrder"]){
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }else{
//            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
//        }
//    }
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
