//
//  HXHistoryCell.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/25.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXHistoryCell.h"

@interface HXHistoryCell ()

@property (nonatomic,strong) NSString *history;

@end

@implementation HXHistoryCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setData:(id)data delegate:(id)delegate {
    if ([data isKindOfClass:[NSString class]]) {
        _delegate = delegate;
        _history = (NSString *)data;
        
        self.historyLabel.text = _history;
    }
}

- (IBAction)deleteButtonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(historyCell:deleteButtonAction:history:)]) {
        [_delegate historyCell:self deleteButtonAction:sender history:_history];
    }
}

@end
