//
//  TZPhotoPreviewController.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZPhotoPreviewController.h"
#import "TZPhotoPreviewCell.h"
#import "TZAssetModel.h"
#import "UIView+Layout.h"
#import "TZImagePickerController.h"
#import "TZImageManager.h"

@interface TZPhotoPreviewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate> {
    UICollectionView *_collectionView;
    BOOL _isHideNaviBar;
    NSArray *_photosTemp;
    NSArray *_assetsTemp;
    
    UIView *_naviBar;
    UIButton *_backButton;
    UIButton *_selectButton;
    
    UIView *_toolBar;
    UIButton *_okButton;
    UIImageView *_numberImageView;
    UILabel *_numberLable;
    UIButton *_originalPhotoButton;
    UILabel *_originalPhotoLable;
    UILabel *_numberImageLabel;
    int _allnumberImage;
    CGFloat _minimumLineSpacing;
}
@end

@implementation TZPhotoPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)weakSelf.navigationController;
    if (!self.models.count) {
        self.models = [NSMutableArray arrayWithArray:_tzImagePickerVc.selectedModels];
        _assetsTemp = [NSMutableArray arrayWithArray:_tzImagePickerVc.selectedAssets];
        self.isSelectOriginalPhoto = _tzImagePickerVc.isSelectOriginalPhoto;
    }
    _minimumLineSpacing = 20;
    [self configCollectionView];
    [self configCustomNaviBar];
    [self configBottomToolBar];
}

- (void)setPhotos:(NSMutableArray *)photos {
    _photos = photos;
    _photosTemp = [NSArray arrayWithArray:photos];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = YES;
    if (_currentIndex) [_collectionView setContentOffset:CGPointMake((self.view.tz_width + _minimumLineSpacing) * _currentIndex, 0) animated:NO];
    [self refreshNaviBarAndBottomBarState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    if (iOS7Later) [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)configCustomNaviBar {
    _naviBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.tz_width, 64)];
    _naviBar.backgroundColor = [UIColor whiteColor];
//    _naviBar.alpha = 0.7;
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 60, 44)];
    [_backButton setImage:[UIImage imageNamed:@"nav_back_red"] forState:UIControlStateNormal];

    _backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton setTitleColor:[UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1] forState:UIControlStateNormal];
    
    _backButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    _selectButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.tz_width - 42, 18, 42, 42)];
    [_selectButton setImage:[UIImage imageNamedFromMyBundle:@"photo_def_photoPickerVc.png"] forState:UIControlStateNormal];
    [_selectButton setImage:[UIImage imageNamedFromMyBundle:@"photo_sel_photoPickerVc.png"] forState:UIControlStateSelected];
    [_selectButton addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    
    _numberImageLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.tz_width/4.0, 32, self.view.tz_width/2.0, 18)];
    _numberImageLabel.font = [UIFont systemFontOfSize:kNavTitleFontSize];
    _numberImageLabel.textColor = [UIColor colorWithRed:(247 / 255.0f) green:(105 / 255.0f) blue:(86 / 255.0f) alpha:1];
    _numberImageLabel.textAlignment = NSTextAlignmentCenter;
    [_naviBar addSubview:_numberImageLabel];
    [_naviBar addSubview:_selectButton];
    [_naviBar addSubview:_backButton];
    [self.view addSubview:_naviBar];
}

- (void)configBottomToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.tz_height - 44, self.view.tz_width, 44)];
//    CGFloat rgb = 34 / 255.0;
    _toolBar.backgroundColor = [UIColor whiteColor];
//    _toolBar.alpha = 0.7;
    
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    _allnumberImage = [[NSString stringWithFormat:@"%zd",_tzImagePickerVc.selectedModels.count] intValue];
//    if (_tzImagePickerVc.allowPickingOriginalPhoto) {
//        _originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _originalPhotoButton.frame = CGRectMake(5, 0, 120, 44);
//        _originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
//        _originalPhotoButton.contentEdgeInsets = UIEdgeInsetsMake(0, -50, 0, 0);
//        _originalPhotoButton.backgroundColor = [UIColor clearColor];
//        [_originalPhotoButton addTarget:self action:@selector(originalPhotoButtonClick) forControlEvents:UIControlEventTouchUpInside];
//        _originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:13];
//        [_originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
//        [_originalPhotoButton setTitle:@"原图" forState:UIControlStateSelected];
//        [_originalPhotoButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//        [_originalPhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
//        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:@"preview_original_def.png"] forState:UIControlStateNormal];
//        [_originalPhotoButton setImage:[UIImage imageNamedFromMyBundle:@"photo_original_sel.png"] forState:UIControlStateSelected];
//        
//        _originalPhotoLable = [[UILabel alloc] init];
//        _originalPhotoLable.frame = CGRectMake(60, 0, 70, 44);
//        _originalPhotoLable.textAlignment = NSTextAlignmentLeft;
//        _originalPhotoLable.font = [UIFont systemFontOfSize:13];
//        _originalPhotoLable.textColor = [UIColor whiteColor];
//        _originalPhotoLable.backgroundColor = [UIColor clearColor];
//        if (_isSelectOriginalPhoto) [self showPhotoBytes];
//    }
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame = CGRectMake(self.view.tz_width - 60 - 12, 0, 60, 44);
    _okButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_okButton addTarget:self action:@selector(okButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_okButton setTitle:[NSString stringWithFormat:@"确定(%zd)",_tzImagePickerVc.selectedModels.count] forState:UIControlStateNormal];
    [_okButton setTitleColor:_tzImagePickerVc.oKButtonTitleColorNormal forState:UIControlStateNormal];
//    _numberImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedFromMyBundle:@"photo_number_icon.png"]];
//    _numberImageView.backgroundColor = [UIColor clearColor];
//    _numberImageView.frame = CGRectMake(self.view.tz_width - 56 - 24, 9, 26, 26);
//    _numberImageView.hidden = _tzImagePickerVc.selectedModels.count <= 0;
    
//    _numberLable = [[UILabel alloc] init];
//    _numberLable.frame = _numberImageView.frame;
//    _numberLable.font = [UIFont systemFontOfSize:16];
//    _numberLable.textColor = [UIColor whiteColor];
//    _numberLable.textAlignment = NSTextAlignmentCenter;
//    _numberLable.text = [NSString stringWithFormat:@"%zd",_tzImagePickerVc.selectedModels.count];
//    _numberLable.hidden = _tzImagePickerVc.selectedModels.count <= 0;
//    _numberLable.backgroundColor = [UIColor clearColor];

    [_originalPhotoButton addSubview:_originalPhotoLable];
    [_toolBar addSubview:_okButton];
//    [_toolBar addSubview:_originalPhotoButton];
//    [_toolBar addSubview:_numberImageView];
//    [_toolBar addSubview:_numberLable];
    [self.view addSubview:_toolBar];
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.tz_width, self.view.tz_height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = _minimumLineSpacing;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.tz_width , self.view.tz_height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.view.tz_width * _models.count, self.view.tz_height);
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TZPhotoPreviewCell class] forCellWithReuseIdentifier:@"TZPhotoPreviewCell"];
}

#pragma mark - Click Event

- (void)select:(UIButton *)selectButton {
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    TZAssetModel *model = _models[_currentIndex];
    if (!selectButton.isSelected) {
        // 1. select:check if over the maxImagesCount / 选择照片,检查是否超过了最大个数的限制
        if (_tzImagePickerVc.selectedModels.count >= _tzImagePickerVc.maxImagesCount) {
            [_tzImagePickerVc showAlertWithTitle:[NSString stringWithFormat:@"你最多只能选择%zd张照片",_tzImagePickerVc.maxImagesCount]];
            return;
        // 2. if not over the maxImagesCount / 如果没有超过最大个数限制
        } else {
            [_tzImagePickerVc.selectedModels addObject:model];
            if (self.photos) {
                [_tzImagePickerVc.selectedAssets addObject:_assetsTemp[_currentIndex]];
                [self.photos addObject:_photosTemp[_currentIndex]];
            }
            if (model.type == TZAssetModelMediaTypeVideo) {
                [_tzImagePickerVc showAlertWithTitle:@"多选状态下选择视频，默认将视频当图片发送"];
            }
        }
    } else {
        NSArray *selectedModels = [NSArray arrayWithArray:_tzImagePickerVc.selectedModels];
        for (TZAssetModel *model_item in selectedModels) {
            if ([[[TZImageManager manager] getAssetIdentifier:model.asset] isEqualToString:[[TZImageManager manager] getAssetIdentifier:model_item.asset]]) {
                [_tzImagePickerVc.selectedModels removeObject:model_item];
                if (self.photos) {
                    [_tzImagePickerVc.selectedAssets removeObject:_assetsTemp[_currentIndex]];
                    [self.photos removeObject:_photosTemp[_currentIndex]];
                }
                break;
            }
        }
    }
    model.isSelected = !selectButton.isSelected;
    [self refreshNaviBarAndBottomBarState];
    if (model.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:selectButton.imageView.layer type:TZOscillatoryAnimationToBigger];
    }
    [UIView showOscillatoryAnimationWithLayer:_numberImageView.layer type:TZOscillatoryAnimationToSmaller];
}

- (void)back {
    if (self.navigationController.childViewControllers.count < 2) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
    if (self.backButtonClickBlock) {
        self.backButtonClickBlock(_isSelectOriginalPhoto);
    }
}

- (void)okButtonClick {
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    if (_tzImagePickerVc.selectedModels.count == 0) {
        TZAssetModel *model = _models[_currentIndex];
        [_tzImagePickerVc.selectedModels addObject:model];
    }
    if (self.okButtonClickBlock) {
        self.okButtonClickBlock(_isSelectOriginalPhoto);
    }
    if (self.okButtonClickBlockWithPreviewType) {
        self.okButtonClickBlockWithPreviewType(self.photos,_tzImagePickerVc.selectedAssets,self.isSelectOriginalPhoto);
    }
}

- (void)originalPhotoButtonClick {
    _originalPhotoButton.selected = !_originalPhotoButton.isSelected;
    _isSelectOriginalPhoto = _originalPhotoButton.isSelected;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) {
        [self showPhotoBytes];
        if (!_selectButton.isSelected) [self select:_selectButton];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offSet = scrollView.contentOffset;
    CGFloat offSetWidth = offSet.x;
    if ((offSetWidth + ((self.view.tz_width + _minimumLineSpacing) * 0.5)) < scrollView.contentSize.width + _minimumLineSpacing) {
        offSetWidth = offSetWidth +  ((self.view.tz_width + _minimumLineSpacing) * 0.5);
    }
    
    NSInteger currentIndex = offSetWidth / (self.view.tz_width + _minimumLineSpacing);
    
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        [self refreshNaviBarAndBottomBarState];
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _models.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TZPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TZPhotoPreviewCell" forIndexPath:indexPath];
    cell.model = _models[indexPath.row];
    [_numberImageLabel setText:[NSString stringWithFormat:@"%ld/%lu",indexPath.row+1,(unsigned long)_models.count]];
    __block BOOL _weakIsHideNaviBar = _isHideNaviBar;
    __weak typeof(_naviBar) weakNaviBar = _naviBar;
    __weak typeof(_toolBar) weakToolBar = _toolBar;
    if (!cell.singleTapGestureBlock) {
        cell.singleTapGestureBlock = ^(){
            // show or hide naviBar / 显示或隐藏导航栏
            _weakIsHideNaviBar = !_weakIsHideNaviBar;
            weakNaviBar.hidden = _weakIsHideNaviBar;
            weakToolBar.hidden = _weakIsHideNaviBar;
        };
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TZPhotoPreviewCell class]]) {
        [(TZPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TZPhotoPreviewCell class]]) {
        [(TZPhotoPreviewCell *)cell recoverSubviews];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    NSInteger MAX_INDEX = (scrollView.contentSize.width + _minimumLineSpacing)/(self.view.tz_width + _minimumLineSpacing) - 1;
    NSInteger MIN_INDEX = 0;
    
    NSInteger index = contentOffsetX/(self.view.tz_width + _minimumLineSpacing);
    
    if (velocity.x > 0.4 && contentOffsetX < (*targetContentOffset).x) {
        index = index + 1;
    }
    else if (velocity.x < -0.4 && contentOffsetX > (*targetContentOffset).x) {
        index = index;
    }
    else if (contentOffsetX > (index + 0.5) * (self.view.tz_width + _minimumLineSpacing)) {
        index = index + 1;
    }
    
    if (index > MAX_INDEX) index = MAX_INDEX;
    if (index < MIN_INDEX) index = MIN_INDEX;
    
    CGPoint newTargetContentOffset= CGPointMake(index * (self.view.tz_width + _minimumLineSpacing), 0);
    *targetContentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    [scrollView setContentOffset:newTargetContentOffset animated:YES];
    
}

#pragma mark - Private Method

- (void)refreshNaviBarAndBottomBarState {
    TZImagePickerController *_tzImagePickerVc = (TZImagePickerController *)self.navigationController;
    TZAssetModel *model = _models[_currentIndex];
    _selectButton.selected = model.isSelected;
    _numberLable.text = [NSString stringWithFormat:@"%zd",_tzImagePickerVc.selectedModels.count];
    _numberImageView.hidden = (_tzImagePickerVc.selectedModels.count <= 0 || _isHideNaviBar);
    _numberLable.hidden = (_tzImagePickerVc.selectedModels.count <= 0 || _isHideNaviBar);
    if (_tzImagePickerVc.selectedModels.count <= 0)
    {
        [_okButton setTitle:@"确定" forState:UIControlStateNormal];
    }
    else
    {
        [_okButton setTitle:[NSString stringWithFormat:@"确定(%zd)",_tzImagePickerVc.selectedModels.count] forState:UIControlStateNormal];
    }

    
    _originalPhotoButton.selected = _isSelectOriginalPhoto;
    _originalPhotoLable.hidden = !_originalPhotoButton.isSelected;
    if (_isSelectOriginalPhoto) [self showPhotoBytes];
    
    // If is previewing video, hide original photo button
    // 如果正在预览的是视频，隐藏原图按钮
    if (_isHideNaviBar) return;
    if (model.type == TZAssetModelMediaTypeVideo) {
        _originalPhotoButton.hidden = YES;
        _originalPhotoLable.hidden = YES;
    } else {
        _originalPhotoButton.hidden = NO;
        if (_isSelectOriginalPhoto)  _originalPhotoLable.hidden = NO;
    }
}

- (void)showPhotoBytes {
    [[TZImageManager manager] getPhotosBytesWithArray:@[_models[_currentIndex]] completion:^(NSString *totalBytes) {
        _originalPhotoLable.text = [NSString stringWithFormat:@"(%@)",totalBytes];
    }];
}

@end
