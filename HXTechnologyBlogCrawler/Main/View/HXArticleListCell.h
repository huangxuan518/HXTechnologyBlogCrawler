//
//  HXArticleListCell.h
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/20.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXArticle.h"

@class HXArticleListCell;

@protocol HXArticleListCellDelegate <NSObject>

- (void)articleListCell:(HXArticleListCell *)cell titleButtonAction:(UIButton *)sender article:(HXArticle *)article;
- (void)articleListCell:(HXArticleListCell *)cell nameButtonAction:(UIButton *)sender article:(HXArticle *)article;

@end

@interface HXArticleListCell : UITableViewCell

@property (nonatomic,weak) id<HXArticleListCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UILabel *sketchLabel;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (void)setData:(id)data key:(NSString *)key delegate:(id)delegate;

+ (float)getCellFrame:(id)msg width:(float)width;

@end
