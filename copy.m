//
//  QMPOISearchResultIndoorRichView.m
//  SOSOMap
//
//  Created by sarah on 15/12/17.
//  Copyright © 2015年 Tencent. All rights reserved.
//

#import "QMPOISearchResultIndoorRichView.h"

@interface QMPOISearchResultIndoorRichView()

@property(nonatomic, strong)IBOutlet UILabel* name;
@property(nonatomic, strong)IBOutlet UILabel* address;
@property(nonatomic, strong)IBOutlet UILabel* distance;
@property(nonatomic, strong)IBOutlet UIImageView* groupOnImageView;
@property(nonatomic, strong)JsonPOIInfo * info;

@end

@implementation QMPOISearchResultIndoorRichView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

- (void)updateRichView:(JsonPOIInfo *)poiInfo {
    [super updateRichView:poiInfo];
    self.info = poiInfo;
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    CGFloat maxNameWidth = CGRectGetWidth(self.frame);
    
    NSString* nameText = [[self class] changeBracketToSBC:self.info.name];
    CGSize nameSize = [[self class] sizeWithFont:[self.name font] constrainedToWidth:maxNameWidth constrainedToHeight:0 lineBreakMode:NSLineBreakByWordWrapping text:nameText];
    CGRect nameFrame = self.name.frame;
    nameFrame.size.width = nameSize.width;
    nameFrame.size.height = nameSize.height;
    self.name.frame = nameFrame;
    self.name.text = nameText;
    
    CGFloat yoffsetForOneLine = CGRectGetMaxY(self.name.frame) + 10;
    
    self.groupOnImageView.hidden = !self.info.isHaveGroupBuy;
    
    if (self.groupOnImageView.hidden == NO)
    {
        CGRect namePosRc = self.name.frame;
        namePosRc.size.width = maxNameWidth;
        
        CGRect groupOnFrame = self.groupOnImageView.frame;
        CGPoint lastNamePos = [QMPOISearchResultRichBaseView getLastLabelWordPosition:self.name.font frame:namePosRc text:self.name.text];
        groupOnFrame.origin.x = lastNamePos.x + kNameGroupOnGap;
        groupOnFrame.origin.y = lastNamePos.y;
        
        self.groupOnImageView.frame = groupOnFrame;
        
        yoffsetForOneLine = CGRectGetMaxY(self.groupOnImageView.frame)+10;
    }
    
    CGFloat maxDesWidth = CGRectGetWidth(self.frame);
    
    NSString* distanceString = [self getDistanceString:self.info];
    self.distance.hidden = distanceString.length == 0;
    //self.distance.hidden = YES;
    
    if (self.distance.hidden == NO)
    {
        self.distance.text = [self getDistanceString:self.info];
        CGSize distanceSize = [[self class] sizeWithFont:[self.distance font] constrainedToWidth:100 constrainedToHeight:CGRectGetHeight(self.distance.frame) lineBreakMode:NSLineBreakByTruncatingTail text:self.distance.text];
        CGRect distanceFrame = self.distance.frame;
        distanceFrame.size.width = distanceSize.width;
        distanceFrame.origin.x = CGRectGetWidth(self.frame)- distanceFrame.size.width;
        distanceFrame.origin.y = yoffsetForOneLine;
        self.distance.frame = distanceFrame;
        
        maxDesWidth = CGRectGetWidth(self.frame) - CGRectGetWidth(distanceFrame) - 4;
    }
    
    self.address.hidden = self.info.indoorMapCategoryString.length <= 0 && self.info.indoorFloorName.length <= 0;
    
    if (self.address.hidden == NO)
    {
        NSString *text = @"";
        
        NSString *class = [self.info indoorMapCategoryString];
        NSString *floor = [self.info indoorFloorName];
        
        if (class.length > 0) {
            text = [text stringByAppendingString:[NSString stringWithFormat:@"%@ | ",class]];
        }
        if (floor.length > 0) {
            text = [text stringByAppendingString:floor];
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        if (text.length > 0 && floor.length >0) {
            
            UIColor *blueColor = UIColorFromHEX(0XFB4234);
            [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, [text length])];
            [attributedString addAttribute:NSForegroundColorAttributeName value:blueColor range:[text rangeOfString:floor]];
            
        }
        
        self.address.attributedText = attributedString;
        CGSize addressSize = [[self class] sizeWithFont:[self.address font] constrainedToWidth:maxDesWidth constrainedToHeight:CGRectGetHeight(self.address.frame) lineBreakMode:NSLineBreakByTruncatingTail text:self.address.text];
        CGRect addressFrame= self.address.frame;
        addressFrame.size.width = addressSize.width;
        addressFrame.origin.y = yoffsetForOneLine;
        self.address.frame= addressFrame;
    }
    
}



+ (CGFloat)heightForInfo:(JsonPOIInfo *)info {
    return 120.0;
}

@end
