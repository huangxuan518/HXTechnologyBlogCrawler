//
//  HXHistoryLastCell.h
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/25.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXHistoryLastCell;

@protocol HXHistoryLastCellDelegate <NSObject>

- (void)historyLastCell:(HXHistoryLastCell *)cell deleteButtonAction:(UIButton *)sender;
- (void)historyLastCell:(HXHistoryLastCell *)cell moreButtonAction:(UIButton *)sender;

@end

@interface HXHistoryLastCell : UITableViewCell

@property (nonatomic,weak) id<HXHistoryLastCellDelegate> delegate;

- (void)setData:(id)data delegate:(id)delegate;

@end
