//
//  HXHistoryLastCell.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/25.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXHistoryLastCell.h"

@interface HXHistoryLastCell ()

@property (nonatomic,strong) NSString *history;

@end

@implementation HXHistoryLastCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setData:(id)data delegate:(id)delegate {
    _delegate = delegate;
}

- (IBAction)deleteButtonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(historyLastCell:deleteButtonAction:)]) {
        [_delegate historyLastCell:self deleteButtonAction:sender];
    }
}

- (IBAction)moreButtonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(historyLastCell:deleteButtonAction:)]) {
        [_delegate historyLastCell:self moreButtonAction:sender];
    }
}

@end
