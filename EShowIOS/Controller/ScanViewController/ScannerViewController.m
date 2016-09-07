//
//  ScannerViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/15.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "ScannerViewController.h"
#import "ScanResultViewController.h"
#import "ScanResultWebViewController.h"
#import "QRCScanner.h"
#import "RegexKitLite.h"
@interface ScannerViewController ()<QRCodeScanneDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
}
@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    QRCScanner *scanner = [[QRCScanner alloc]initQRCScannerWithView:self.view];
    scanner.delegate = self;
    [self.view addSubview:scanner];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(readerImage)];
}
#pragma mark - 扫描二维码成功后结果的代理方法
- (void)didFinshedScanningQRCode:(NSString *)result
{
    if (result.length > 0)
    {
        if ([result isMatchedByRegex:@"[a-zA-z]+://[^//s]*"])
        {
            ScanResultWebViewController *scan = [[ScanResultWebViewController alloc] init];
            scan.url = result;
            scan.title= @"扫一扫";
            [self.navigationController pushViewController:scan animated:YES];
        }
        else
        {
            ScanResultViewController *scan = [[ScanResultViewController alloc] init];
            scan.resultStr = result;
            scan.title = @"扫一扫";
            [self.navigationController pushViewController:scan animated:YES];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统提示" message:@"暂未发现二维码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
   
}
#pragma mark - 从相册获取二维码图片
- (void)readerImage{
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoPicker.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *srcImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *result = [QRCScanner scQRReaderForImage:srcImage];
    if (result.length > 0)
    {
        if ([result isMatchedByRegex:@"[a-zA-z]+://[^//s]*"])
        {
            ScanResultWebViewController *scan = [[ScanResultWebViewController alloc] init];
            scan.url = result;
            scan.title= @"扫一扫";
            [self.navigationController pushViewController:scan animated:YES];
        }
        else
        {
            ScanResultViewController *scan = [[ScanResultViewController alloc] init];
            scan.resultStr = result;
            scan.title = @"扫一扫";
            [self.navigationController pushViewController:scan animated:YES];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统提示" message:@"暂未发现二维码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
   
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
//    scanner = [[QRCScanner alloc]initQRCScannerWithView:self.view];
//    scanner.delegate = self;
//    [self.view addSubview:scanner];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [scanner removeFromSuperview];
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
