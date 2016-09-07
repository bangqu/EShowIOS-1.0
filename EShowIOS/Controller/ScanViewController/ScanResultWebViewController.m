//
//  ScanResultWebViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/15.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "ScanResultWebViewController.h"
#import "ContentViewController.h"
@interface ScanResultWebViewController ()<UIWebViewDelegate>
@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, weak) UIButton * backItem;
@property (nonatomic, weak) UIButton * closeItem;
@property (nonatomic, weak) UIActivityIndicatorView * activityView;
@end

@implementation ScanResultWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWebView];
    [self initNaviBar];
}
- (void)initWebView
{
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    
    //activityView
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = self.view.center;
    [activityView startAnimating];
    self.activityView = activityView;
    [self.view addSubview:activityView];
    
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0]];
}
- (void)initNaviBar{
    
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    UIButton * backItem = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    [backItem setImage:[UIImage imageNamed:@"navi_back_red_new"] forState:UIControlStateNormal];
    
    [backItem setTitle:@"返回" forState:UIControlStateNormal];
    [backItem.titleLabel setFont:[UIFont systemFontOfSize:18]];
    //    [backItem setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    backItem.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
    [backItem setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [backItem setTitleColor:[UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1] forState:UIControlStateNormal];
    [backItem addTarget:self action:@selector(clickedBackItem:) forControlEvents:UIControlEventTouchUpInside];
    self.backItem = backItem;
    [backView addSubview:backItem];
    //    UIButton * closeItem = [[UIButton alloc]initWithFrame:CGRectMake(44+12, 0, 44, 44)];
    //    [closeItem setTitle:@"关闭" forState:UIControlStateNormal];
    //    [closeItem setTitleColor:[UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1] forState:UIControlStateNormal];
    //    [closeItem addTarget:self action:@selector(clickedCloseItem:) forControlEvents:UIControlEventTouchUpInside];
    //    closeItem.hidden = YES;
    //    self.closeItem = closeItem;
    //    [backView addSubview:closeItem];
    
    UIBarButtonItem * leftItemBar = [[UIBarButtonItem alloc]initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = leftItemBar;
}
#pragma mark - clickedBackItem
- (void)clickedBackItem:(UIBarButtonItem *)btn{
    if (self.webView.canGoBack) {
        [self.webView goBack];
        //        self.closeItem.hidden = NO;
    }else{
        [self clickedCloseItem:nil];
    }
}
#pragma mark - clickedCloseItem
- (void)clickedCloseItem:(UIButton *)btn{
    for (UIViewController *temp in self.navigationController.viewControllers) {
        if ([temp isKindOfClass:[ContentViewController class]]) {
            [self.navigationController popToViewController:temp animated:YES];
        }
    }
//    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.activityView.hidden = NO;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    
    NSLog(@"url: %@", request.URL.absoluteURL.description);
    
    if (self.webView.canGoBack) {
        self.closeItem.hidden = NO;
    }
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.activityView.hidden = YES;
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.activityView.hidden = YES;
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
