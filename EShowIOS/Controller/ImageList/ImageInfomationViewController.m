//
//  ImageInfomationViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/2.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "ImageInfomationViewController.h"
#import "ImageInfoCollectionViewCell.h"
#import "ImageInfoModel.h"
#import "SDPhotoBrowser.h"
@interface ImageInfomationViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,SDPhotoBrowserDelegate>
{
}
@property (nonatomic, strong) NSMutableArray *modelsArray;
@end

@implementation ImageInfomationViewController
+ (instancetype)demoCollectionViewController
{
    CGFloat w = ([UIScreen mainScreen].bounds.size.width-80)/2.0 ;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(w, w);
    layout.minimumInteritemSpacing = 10;
    return [[ImageInfomationViewController alloc] initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"官方相册";
    self.collectionView.backgroundColor = [UIColor colorWithRed:242/255.0 green:245/255.0 blue:233/255.0 alpha:1.0f];
    
    [self.collectionView registerClass:[ImageInfoCollectionViewCell class] forCellWithReuseIdentifier:@"NewCell"];
    
    NSArray *srcStringArray = @[@"http://ww2.sinaimg.cn/thumbnail/904c2a35jw1emu3ec7kf8j20c10epjsn.jpg",
                                @"http://ww2.sinaimg.cn/thumbnail/98719e4agw1e5j49zmf21j20c80c8mxi.jpg",
                                @"http://ww2.sinaimg.cn/thumbnail/67307b53jw1epqq3bmwr6j20c80axmy5.jpg",
                                @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
                                @"http://ww2.sinaimg.cn/thumbnail/642beb18gw1ep3629gfm0g206o050b2a.gif",
                                @"http://ww1.sinaimg.cn/thumbnail/9be2329dgw1etlyb1yu49j20c82p6qc1.jpg"
                                ];
    NSMutableArray *temp = [NSMutableArray new];
    for (int i = 0; i < 10; i++) {
        int index = arc4random_uniform((int)srcStringArray.count);
        ImageInfoModel *item = [ImageInfoModel new];
        item.thumbnail_pic = srcStringArray[index];
        [temp addObject:item];
    }
    
    self.modelsArray = [temp copy];

//    _dataArray = [NSMutableArray array];
//    NSMutableArray *NewArrList = [NSMutableArray new];
//    for (int i =0 ; i < 10; i ++)
//    {
//        UIImage *image = [UIImage imageNamed:@"NewImage.jpg"];
//        [NewArrList addObject:image];
//    }
//    _dataArray = NewArrList;
//    [self initCollectionView];
}
- (void)initCollectionView
{
    //创建布局
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor colorWithRed:242/255.0 green:245/255.0 blue:233/255.0 alpha:1.0f];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    //注册重复使用的cell
    [self.collectionView registerClass:[ImageInfoCollectionViewCell class] forCellWithReuseIdentifier:@"NewCell"];
    
    NSArray *srcStringArray = @[@"http://ww2.sinaimg.cn/thumbnail/904c2a35jw1emu3ec7kf8j20c10epjsn.jpg",
                                @"http://ww2.sinaimg.cn/thumbnail/98719e4agw1e5j49zmf21j20c80c8mxi.jpg",
                                @"http://ww2.sinaimg.cn/thumbnail/67307b53jw1epqq3bmwr6j20c80axmy5.jpg",
                                @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg",
                                @"http://ww1.sinaimg.cn/thumbnail/9be2329dgw1etlyb1yu49j20c82p6qc1.jpg"
                                ];
    NSMutableArray *temp = [NSMutableArray new];
    self.modelsArray = [NSMutableArray new];
    for (int i = 0; i < 10; i++) {
        int index = arc4random_uniform((int)srcStringArray.count);
        ImageInfoModel *item = [ImageInfoModel new];
        item.thumbnail_pic = srcStringArray[index];
        [temp addObject:item];
    }
    
    self.modelsArray = [temp copy];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.collectionView addGestureRecognizer:longPress];
}
- (void)longPress:(UILongPressGestureRecognizer *)longPress{
    UIGestureRecognizerState state = longPress.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:{
            CGPoint pressPoint = [longPress locationInView:self.collectionView];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pressPoint];
            if (!indexPath) {
                break;
            }
            [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            CGPoint pressPoint = [longPress locationInView:self.collectionView];
            [self.collectionView updateInteractiveMovementTargetPosition:pressPoint];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            [self.collectionView endInteractiveMovement];
            break;
        }
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}
#pragma mark- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.modelsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"NewCell" forIndexPath:indexPath];
//    UIImageView *backimageView = [[UIImageView alloc] init];
//    backimageView.backgroundColor = [UIColor whiteColor];
//    UIImageView *imageView = [[UIImageView alloc] init];
//    [imageView yy_setImageWithURL:nil options:YYWebImageOptionShowNetworkActivity];
//    //    imageView.backgroundColor = [UIColor grayColor];
//    imageView.image = _dataArray[indexPath.row];
//    [backimageView addSubview:imageView];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.and.right.equalTo(backimageView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
//    }];
////    UILabel *titleLabel = [UILabel new];
////    [imageView addSubview:titleLabel];
////    titleLabel.backgroundColor = [UIColor blackColor];
////    titleLabel.alpha = 0.6;
////    titleLabel.textColor = [UIColor whiteColor];
////    titleLabel.text = @"官方相册";
////    titleLabel.textAlignment = NSTextAlignmentCenter;
////    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.bottom.equalTo(imageView.mas_bottom);
////        make.left.equalTo(imageView.mas_left);
////        make.right.equalTo(imageView.mas_right);
////        make.height.mas_equalTo(@30);
////    }];
////    titleLabel.font = [UIFont systemFontOfSize:16];
//    
//    cell.backgroundView = backimageView;
//    cell.backgroundColor = [UIColor whiteColor];
//    return cell;
    ImageInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewCell" forIndexPath:indexPath];
    cell.item = self.modelsArray[indexPath.item];
    return cell;

}

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 3;
//}

//- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath{
    id obj = [self.modelsArray objectAtIndex:sourceIndexPath.item];
    [self.modelsArray removeObject:obj];
    [self.modelsArray insertObject:obj atIndex:destinationIndexPath.item];
}
#pragma mark - UICollectionViewDelegateFlowLayout
//设置cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = CGSizeMake(([UIScreen mainScreen].bounds.size.width-80)/2.0, ([UIScreen mainScreen].bounds.size.width-80)/2.0);
    return size;
}

//设置cell与边缘的间隔
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 26, 0, 26);
    return inset;
}

//最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 37;
}
//设置header高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size = CGSizeMake(0, 26);
    return size;
}

//设置footer高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGSize size = CGSizeMake(0, 26);
    return size;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
    photoBrowser.delegate = self;
    photoBrowser.currentImageIndex = indexPath.item;
    photoBrowser.imageCount = self.modelsArray.count;
    photoBrowser.sourceImagesContainerView = self.collectionView;
    
    [photoBrowser show];

}
#pragma mark  SDPhotoBrowserDelegate

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    // 不建议用此种方式获取小图，这里只是为了简单实现展示而已
    ImageInfoCollectionViewCell *cell = (ImageInfoCollectionViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    
    return cell.imageView.image;
    
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *urlStr = [[self.modelsArray[index] thumbnail_pic] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
    return [NSURL URLWithString:urlStr];
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
