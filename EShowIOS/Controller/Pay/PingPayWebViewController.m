//
//  PingPayWebViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/16.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "PingPayWebViewController.h"
#import "MBProgressHUD.h"

#import "Pingpp.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "NJKWebViewProgressView.h"
#import "PingPaySuccessWebViewController.h"

#define kWaiting          @"正在获取支付凭据,请稍后..."
#define kNote             @"提示"
#define kConfirm          @"确定"
#define kErrorNet         @"网络错误"
#define kResult           @"支付结果：%@"

#define kUrlScheme  @"fuckEShow"

@interface PingPayWebViewController () {
    
    MBProgressHUD * hud;
    NSURL *lastUrl;
    NSString *url;
}

@end

@implementation PingPayWebViewController
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

- (void)dealloc
{
    self.channel = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //后退
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    UIButton * backItem = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 44)];
    [backItem setImage:[UIImage imageNamed:@"navi_back_red_new"] forState:UIControlStateNormal];
    
    [backItem setTitle:@"返回" forState:UIControlStateNormal];
    [backItem.titleLabel setFont:[UIFont systemFontOfSize:18]];
    //    [backItem setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    backItem.contentEdgeInsets = UIEdgeInsetsMake(0, -35, 0, 0);
    [backItem setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [backItem setTitleColor:[UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1] forState:UIControlStateNormal];
    [backItem addTarget:self action:@selector(backBack) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:backItem];

    UIBarButtonItem * leftItemBar = [[UIBarButtonItem alloc]initWithCustomView:backView];
    self.navigationItem.leftBarButtonItem = leftItemBar;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callBackNoti) name:kAliPayCallBackNoti object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(back) name:kAliPayCancelNoti object:nil];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.view.backgroundColor = [UIColor whiteColor];
  
    
    [self setLoadingStyle];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 设置延时，单位秒
    double delay = 1.0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), queue, ^{
        // 3秒后需要执行的任务
        self.urlString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self.urlString, nil, nil, kCFStringEncodingUTF8));
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0]];
        lastUrl = [NSURL URLWithString:self.urlString];
    });
}
-(void)backBack{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否退出" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil ];
    alert.delegate = self;
    [alert show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==1){
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void) setLoadingStyle
{
    
    CGFloat with = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,with,height)];
    [self.view addSubview:self.webView];
    
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;

    CGFloat progressBarHeight = 2.5f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _progressView.backgroundColor = [UIColor whiteColor];
    _progressView.progressBarView.backgroundColor = [UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_progressView removeFromSuperview];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    
    [_progressView setProgress:progress animated:YES];
//    [_progressView.progressBarView setBackgroundColor:[UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:0.5]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark --webView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
//    NSString *protocol = [NSString stringWithFormat:@"https://wap.koudaitong.com/v2/tag/w0dkel6i?reft=1473039949272&spm=sc1240852"];
    NSString *protocol = [NSString stringWithFormat:@"%@pingpay/ping-pay!",BaseUrl];
    url =  [[request URL] absoluteString];
    if ([requestString hasPrefix:protocol]) {
        NSString *str = [requestString substringFromIndex:[protocol length]];
        NSString *host = [str substringToIndex:[str rangeOfString:@"?"].location];
        NSString *paramString = [str substringFromIndex:[str rangeOfString:@"?"].location+1];
        NSMutableDictionary *queryStringDict = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [paramString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            [queryStringDict setObject:value forKey:key];
        }
        if ([host isEqualToString:@"pay.action"]) {
            self.urlFormJs = requestString;
            [self payWithChannel:[queryStringDict objectForKey:@"channel"] amount:[queryStringDict objectForKey:@"amount"]];
        }
        return NO;
    }
    
//    //判断是否是单击
//    if (navigationType == UIWebViewNavigationTypeLinkClicked)
//    {
//        if ([[XJUserDefaults objectForKey:@"playBack"] isEqualToString:@"xinbiku"]) {
//            [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
//        }else{
//            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
//        }
//        //[self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
//    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // 页面 js 调用方法：PINGPP_IOS_SDK.callPay(channel, amount)
    NSString *js = @"(function() {\
    window.PINGPP_IOS_SDK = {};\
    window.PINGPP_IOS_SDK.callPay = function(url) {\
    location.href = url;\
    };\
    return true;\
    })();";
    [webView stringByEvaluatingJavaScriptFromString:js];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)showAlertWait
{
    mAlert = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [mAlert show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(mAlert.frame.size.width / 2.0f - 15, mAlert.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [mAlert addSubview:aiv];
}

- (void)showAlertMessage:(NSString*)msg
{
    mAlert = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:nil cancelButtonTitle:kConfirm otherButtonTitles:nil, nil];
    [mAlert show];
}

- (void)hideAlert
{
    if (mAlert != nil)
    {
        [mAlert dismissWithClickedButtonIndex:0 animated:YES];
        mAlert = nil;
    }
}

- (void)payWithChannel:(NSString *)ch amount:(NSString *)amount
{
    if (![ch isEqualToString:@"wx"]
        && ![ch isEqualToString:@"alipay"]
        ) {
        return;
    }
    self.channel = ch;
    
    long long amountl = [[amount stringByReplacingOccurrencesOfString:@"." withString:@""] longLongValue];
    if (amountl == 0) {
        return;
    }
    NSString *amountStr = [NSString stringWithFormat:@"%lld", amountl];
    NSURL* newurl = [NSURL URLWithString:self.urlFormJs];
    NSMutableURLRequest * postRequest=[NSMutableURLRequest requestWithURL:newurl];
    
    NSDictionary* dict = @{
                           @"channel" : self.channel,
                           @"amount"  : amountStr
                           };
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [postRequest setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection* urlConn = [[NSURLConnection alloc] initWithRequest:postRequest delegate:self];
    [urlConn start];
    [self showAlertWait];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    NSHTTPURLResponse* rsp = (NSHTTPURLResponse*)response;
    long code = [rsp statusCode];
    if (code != 200)
    {
        [self hideAlert];
        [self showAlertMessage:kErrorNet];
        [connection cancel];
        connection = nil;
    }
    else
    {
        if (mData != nil)
        {
            mData = nil;
        }
        mData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [mData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self hideAlert];
    NSString* data = [[NSMutableString alloc] initWithData:mData encoding:NSUTF8StringEncoding];
    if (data != nil && data.length > 0) {
        PingPayWebViewController * __weak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [Pingpp createPayment:data viewController:weakSelf appURLScheme:kUrlScheme withCompletion:^(NSString *result, PingppError *error) {
                NSLog(@"completion block: %@", result);
                if (error == nil) {
                    NSLog(@"PingppError is nil");
                } else {
                    //                    NSLog(@"PingppError: code=%lu msg=%@", (unsigned  long)error.code, [error getMsg]);
                }
                if ([result isEqualToString:@"success"]) {
                    [self callBackNoti];
                }else{
                    [self back];
                }
                [weakSelf showAlertMessage:result];
            }];
        });
        
        
    }
    connection = nil;
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self hideAlert];
    [self showAlertMessage:kErrorNet];
    connection = nil;
}

- (void)callBackNoti
{
    PingPaySuccessWebViewController *vc = [[PingPaySuccessWebViewController alloc]init];
    vc.titleString = @"支付成功";
    vc.urlString = [NSString stringWithFormat:@"%@pingpay/success.jsp",BaseUrl];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)back
{
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
}

@end

