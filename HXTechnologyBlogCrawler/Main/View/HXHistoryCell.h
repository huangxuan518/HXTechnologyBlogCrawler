//
//  HXHistoryCell.h
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/25.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXHistoryCell;

@protocol HXHistoryCellDelegate <NSObject>

- (void)historyCell:(HXHistoryCell *)cell deleteButtonAction:(UIButton *)sender history:(NSString *)history;

@end

@interface HXHistoryCell : UITableViewCell

@property (nonatomic,weak) id<HXHistoryCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;

- (void)setData:(id)data delegate:(id)delegate;

@end
