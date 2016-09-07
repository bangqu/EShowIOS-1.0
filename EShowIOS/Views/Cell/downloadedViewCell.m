//
//  downloadedViewCell.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/23.
//  Copyright © 2016年 金璟. All rights reserved.
//

#import "downloadedViewCell.h"

@implementation downloadedViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setFileInfo:(ZFFileModel *)fileInfo
{
    _fileInfo = fileInfo;
    NSString *totalSize = [ZFCommonHelper getFileSizeString:fileInfo.fileSize];
    self.fileNameLabel.text = fileInfo.fileName;
    self.sizeLabel.text = totalSize;
}
@end
