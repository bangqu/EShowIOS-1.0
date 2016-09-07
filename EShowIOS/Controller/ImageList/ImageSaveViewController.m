//
//  ImageSaveViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/3.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "ImageSaveViewController.h"
#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import "ImageSaveCollectionViewCell.h"
#import "NetworkEngine.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "QiniuSDK.h"
#import "WYJCollectionViewFlowLayout.h"
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TPKeyboardAvoidingCollectionView.h"
@interface ImageSaveViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UITextFieldDelegate,TZImagePickerControllerDelegate>
{
    NSArray *photosArray;              //已选照片数组
    UITextField *albumeName;           //相册名称
    NSMutableArray *imageStrArr;       //上传图片的String对象
    NSMutableArray *_selectedPhotos;   //CollectionCell中所有的对象
    NSMutableArray *_selectedAssets;
    BOOL _isSelectOriginalPhoto;
    NSString *QINIUKey;
    NSString *QINIUToken;
    NSString *userToken;
    NSString *imageFilePath;           //图片地址
    CGFloat _itemWH;                   //CollectionCell的宽度
    CGFloat _margin;                   //间隔
    int photoNumber;                   //上传图片的数量
    MBProgressHUD *hud;
    WYJCollectionViewFlowLayout *_layout;
}
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ImageSaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"添加相册";
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(ImageSaveButton:)]];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:245/255.0 blue:233/255.0 alpha:1.0f];
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    imageStrArr = [NSMutableArray array];
    photoNumber = 1;
    [self setCollectionView];
    
}
- (void)setCollectionView
{
    UIView *backView = [UIView new];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backView];
    albumeName = [UITextField new];
    albumeName.placeholder = @"请输入相册名称";
    albumeName.delegate = self;
    albumeName.borderStyle = UITextBorderStyleNone;
    albumeName.font = [UIFont systemFontOfSize:16.0];
    albumeName.returnKeyType = UIReturnKeyDone;
    [backView addSubview:albumeName];
    UILabel *grayline = [UILabel new];
    grayline.backgroundColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0];
    [backView addSubview:grayline];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(80);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(@53.5);
    }];
    [albumeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backView.mas_top).offset(30);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(@23);
    }];
    [grayline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backView.mas_top).offset(53);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(@0.5);
    }];
    _layout = [[WYJCollectionViewFlowLayout alloc] init];
    _margin = 10;
    _itemWH = (ScreenWidth - 5 * _margin) / 4.0;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = _margin;
   _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 133.5, ScreenWidth, 130) collectionViewLayout:_layout];
//    CGFloat rgb = 244 / 255.0;
//    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.bounces = NO;
    _collectionView.alwaysBounceVertical = NO;
    _collectionView.alwaysBounceHorizontal = NO;
    _collectionView.scrollEnabled = NO;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[ImageSaveCollectionViewCell class] forCellWithReuseIdentifier:@"ImageSaveCell"];
    
}
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}
#pragma mark UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selectedPhotos.count < 9)
    {//图片小于9张显示添加图片按钮
        return _selectedPhotos.count + 1;
    }
    else
    {//隐藏添加图片按钮
        return _selectedPhotos.count;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageSaveCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageSaveCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (_selectedPhotos.count < 9)
    {
        if (indexPath.row == _selectedPhotos.count) {
            cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn.png"];
            cell.deleteBtn.hidden = YES;
        } else {
            cell.imageView.image = _selectedPhotos[indexPath.row];
            cell.asset = _selectedAssets[indexPath.row];
            cell.deleteBtn.hidden = NO;
        }
    }
    else
    {
        cell.imageView.image = _selectedPhotos[indexPath.row];
        cell.asset = _selectedAssets[indexPath.row];
        cell.deleteBtn.hidden = NO;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedPhotos.count)
    {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机拍摄",@"手机相册", nil];
        [sheet showInView:self.view];
    } else { // preview photos or video / 预览照片或者视频
        id asset = _selectedAssets[indexPath.row];
        BOOL isVideo = NO;
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = asset;
            isVideo = phAsset.mediaType == PHAssetMediaTypeVideo;
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = asset;
            isVideo = [[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
        }
        if (isVideo) { // perview video / 预览视频
            TZVideoPlayerController *vc = [[TZVideoPlayerController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypeVideo timeLength:@""];
            vc.model = model;
            [self presentViewController:vc animated:YES completion:nil];
        } else { // preview photos / 预览照片
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
            imagePickerVc.allowPickingOriginalPhoto = YES;
            imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                _selectedPhotos = [NSMutableArray arrayWithArray:photos];
                _selectedAssets = [NSMutableArray arrayWithArray:assets];
                _isSelectOriginalPhoto = isSelectOriginalPhoto;
                _layout.itemCount = _selectedPhotos.count;
                [_collectionView reloadData];
                _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
            }];
            [self presentViewController:imagePickerVc animated:YES completion:nil];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.item >= _selectedPhotos.count || destinationIndexPath.item >= _selectedPhotos.count) return;
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    if (image) {
        [_selectedPhotos exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
        [_selectedAssets exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
        [_collectionView reloadData];
    }
}

#pragma mark - TZImagePickerController

- (void)pushImagePickerController {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    // 1.如果你需要将拍照按钮放在外面，不要传这个参数
    imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
//    imagePickerVc.navigationBar = [UINavigationBar appearance];
    [imagePickerVc.navigationBar setBackgroundColor:[UIColor whiteColor]];
    [imagePickerVc.navigationBar setTintColor:[UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1]];//返回按钮的箭头颜色
    NSDictionary *textAttributes = @{
                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:kNavTitleFontSize],
                                     NSForegroundColorAttributeName: [UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1],
                                     };
    [imagePickerVc.navigationBar setTitleTextAttributes:textAttributes];

//     imagePickerVc.navigationBar.barTintColor = [UIColor whiteColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
//    imagePickerVc.allowPickingVideo = self.allowPickingVideoSwitch.isOn;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = NO;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        photosArray = photos;
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS8Later) {
        // 无权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else { // 调用相机
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerVc.sourceType = sourceType;
            if(iOS8Later) {
                _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            [self presentViewController:_imagePickerVc animated:YES completion:nil];
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        tzImagePickerVc.sortAscendingByModificationDate = YES;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image completion:^{
            [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                    [tzImagePickerVc hideProgressHUD];
                    TZAssetModel *assetModel = [models firstObject];
                    if (tzImagePickerVc.sortAscendingByModificationDate) {
                        assetModel = [models lastObject];
                    }
                    [_selectedAssets addObject:assetModel.asset];
                    [_selectedPhotos addObject:image];
                    [_collectionView reloadData];
                }];
            }];
        }];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
    }
    return YES;
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // take photo / 去拍照
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self pushImagePickerController];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=Photos"]];
        }
    }
}

#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
// - (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
// NSLog(@"cancel");
// }

// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    _layout.itemCount = _selectedPhotos.count;
    if (_selectedPhotos.count < 9)
    {
        if (_selectedPhotos.count/4 > 0)
        {
            _collectionView.frame = CGRectMake(0, 133.5, ScreenWidth, 130+(_selectedPhotos.count/4)*_itemWH);
        }
    }
    else
    {
        _collectionView.frame = CGRectMake(0, 133.5, ScreenWidth, 130+(_selectedPhotos.count/4)*_itemWH);
    }
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    _layout.itemCount = _selectedPhotos.count;
    //  打开这段代码发送视频
    // [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
    // NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
    // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    
    // }];
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}


#pragma mark Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
//    if (_selectedPhotos.count ==8)
//    {
//        _layout.itemCount = _selectedPhotos.count+1;
//    }
//    else
//    {
//        _layout.itemCount = _selectedPhotos.count;
//    }
    _collectionView.frame = CGRectMake(0, 133.5, ScreenWidth, 130+(_selectedPhotos.count/4)*_itemWH);
    [_collectionView reloadData];

//    [_collectionView performBatchUpdates:^{
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
//        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
//    } completion:^(BOOL finished) {
//         _collectionView.frame = CGRectMake(0, 133.5, self.view.tz_width, 130+(_selectedPhotos.count/4)*_itemWH);
//        [_collectionView reloadData];
//    }];
}

- (void)ImageSaveButton:(id)sender
{
    [[NetworkEngine sharedManager] getQINIUKey:nil
                                           url:nil
                                  successBlock:^(id responseBody){
                                      if ([responseBody[@"status"] intValue] == 1)
                                      {
                                          QINIUKey = [NSString stringWithFormat:@"%@.png",responseBody[@"msg"]];
                                          [[NetworkEngine sharedManager] getQINIUToken:nil
                                                                                   url:nil
                                                                          successBlock:^(id responseBody){
                                                                              if ([responseBody[@"status"] intValue] == 1)
                                                                              {
                                                                                  QINIUToken = responseBody[@"msg"];
                                                                                  [self uploadImage:photosArray[0]];
                                                                              }
                                                                          }
                                                                          failureBlock:^(NSString *error){
                                                                              NSLog(@"%@",error);
                                                                              
                                                                          }];
                                      }
                                  }
                                  failureBlock:^(NSString *error){
                                      NSLog(@"%@",error);
                                      
                                  }];
    

//    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_queue_t queue1=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 1);
//    dispatch_async(queue,
//                   ^{
//                       dispatch_group_t group=dispatch_group_create();
//                       dispatch_group_async(group, queue, ^{
//                           [[NetworkEngine sharedManager] getQINIUKey:nil
//                                                                  url:nil
//                                                         successBlock:^(id responseBody){
//                                                             if ([responseBody[@"status"] intValue] == 1)
//                                                             {
//                                                                 QINIUKey = [NSString stringWithFormat:@"%@.png",responseBody[@"msg"]];
//                                                                 [[NetworkEngine sharedManager] getQINIUToken:nil
//                                                                                                          url:nil
//                                                                                                 successBlock:^(id responseBody){
//                                                                                                     if ([responseBody[@"status"] intValue] == 1)
//                                                                                                     {
//                                                                                                         QINIUToken = responseBody[@"msg"];
//                                                                                                     }
//                                                                                                 }
//                                                                                                 failureBlock:^(NSString *error){
//                                                                                                     NSLog(@"%@",error);
//
//                                                                                                 }];
//                                                             }
//                                                         }
//                                                         failureBlock:^(NSString *error){
//                                                             NSLog(@"%@",error);
//                                                             
//                                                         }];
//                       });
//                       dispatch_async(dispatch_get_main_queue(), ^{
//                           NSLog(@"%@%@",QINIUKey,QINIUToken);
//                       });
//                });
   

}
#pragma mark - 保存图片至沙盒
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    imageName = [imageName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.01);
    // 获取沙盒目录
    imageFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:imageFilePath atomically:NO];
}
#pragma mark 赋值图片的名称
- (NSString *) timeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    return [formatter stringFromDate:[NSDate date]];
}
#pragma mark 图片通过QINIU转换
- (void)uploadImage:(UIImage *)image
{
     NSLog(@"%@%@",QINIUKey,QINIUToken);
    [self saveImage:image withName:[self timeString]];
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSData *dateeee = [NSData dataWithContentsOfFile:imageFilePath];
    [upManager putData:dateeee
                   key:QINIUKey
                 token:QINIUToken
              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                  NSLog(@"%@",resp);
                  NSString *photoUrl = [NSString stringWithFormat:@"http://eshow.u.qiniudn.com/%@",QINIUKey];
                  [imageStrArr addObject:photoUrl];
                  if (photosArray.count>photoNumber) {
                      [self uploadImage:photosArray[photoNumber]];
                      photoNumber++;
                  }else{
                      if (imageStrArr.count==1) {
                          NSString *url = imageStrArr[0];
                          [self uploadInfo:url];
                      }else if (imageStrArr.count>1){
                          NSString *url = [imageStrArr componentsJoinedByString:@","];
                          [self uploadInfo:url];
                          
                      }else{
//                          [JKUtil showError:@"发布失败" addToView:self.view];
//                          [hud2 removeFromSuperview];
                      }
                      
                  }
                  
              }
                option:nil];

}
#pragma mark 上传图片
-(void)uploadInfo:(NSString *)imgUrlStr
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    if (!(albumeName.text.length > 0))
    {
       hud.label.text = @"请输入相册名称";
       [hud hideAnimated: YES afterDelay: 2];
       return;
    }
    else if (!(photosArray.count > 0))
    {
        hud.label.text = @"请选择需要上传的图片";
        [hud hideAnimated: YES afterDelay: 2];
        return;
    }
    else
    {
        [hud removeFromSuperview];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    userToken = [userDefault objectForKey:@"accessTokenLogin"];
    [[NetworkEngine sharedManager] saveImageList:@{
                                                      @"accessToken":userToken,
                                                      @"photos":imageStrArr,
                                                      @"album.name":@"测试",
                                                      @"album.description":@"",
                                                      @"album.website":@""
                                                          }
                                                    url:nil
                                           successBlock:^(id responseBody){
                                               if ([responseBody[@"status"] intValue] == 1)
                                               {
                                                   
                                               }
//                                               NSMutableArray *NewArrList = [NSMutableArray new];
//                                               NewArrList=[ImageListModel objectArrayWithKeyValuesArray:[responseBody objectForKey:@"albums"]];
//                                               _dataArray = NewArrList;
//                                               _collectionView.mj_footer.hidden = _dataArray.count==0?YES:NO;
//                                               [self doneWithView:self.myRefreshView];

                                           }
                                           failureBlock:^(NSString *error){


                                           }];
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
