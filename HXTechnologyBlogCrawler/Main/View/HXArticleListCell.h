//
//  HXArticleListCell.h
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/20.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXArticleListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UILabel *sketchLabel;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recommendcountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentcountLabel;
@property (weak, nonatomic) IBOutlet UILabel *readcountLabel;

+ (float)getCellFrame:(id)msg width:(float)width;

@end
