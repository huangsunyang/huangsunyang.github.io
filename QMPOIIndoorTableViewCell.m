//
//  QMPOIIndoorTableViewCell.m
//  SOSOMap
//
//  Created by foogrywang(王中周) on 2017/7/18.
//  Copyright © 2017年 Tencent. All rights reserved.
//
//
//                             +----> commonLabels
//                             |
//   +=========================|====+
//   | +-----------------------|--+ |
//   | |                          | |
//   | |                          | |
//   | +--------------------------+ |
//   +==============================+

#import "QMPOIIndoorTableViewCell.h"
#import "JsonPOIInfo+POIList.h"

#import "QMPOICommonDefine.h"
#import "QMPOIIndoorRichView.h"
#import "QMPOISearchResultRichBaseView.h"

@interface QMPOIIndoorTableViewCell ()

@property (strong, nonatomic) QMPOIIndoorRichView * commonLabels;
@property (strong, nonatomic) JsonPOIInfo * info;

@end

@implementation QMPOIIndoorTableViewCell

# pragma mark - view life cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.commonLabels = [[QMPOIIndoorRichView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.commonLabels];
    }
    
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) updateView {
    self.commonLabels.info = self.info;
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    float commonLabelsWidth = self.width - kTableCellLeftMargin - kTableCellRightMargin;
    float commonLabelsHeight = [QMPOISearchResultRichBaseView
                                getHeightOfRichViewWithWidth:self.info
                                width:commonLabelsWidth];
    self.commonLabels.frame = CGRectMake(kTableCellTopMargin, kTableCellLeftMargin,
                                         commonLabelsWidth, commonLabelsHeight);
}

# pragma mark - setter

- (void) setInfo:(JsonPOIInfo *)info {
    _info = info;
    [self updateView];
}


# pragma mark - static method

+ (CGFloat) heightForInfo: (JsonPOIInfo *) info {
    float commLabelHeight = [QMPOIIndoorRichView heightForInfo:info];
    return commLabelHeight + kTableCellTopMargin + kTableCellBottomMargin;
 }

@end
