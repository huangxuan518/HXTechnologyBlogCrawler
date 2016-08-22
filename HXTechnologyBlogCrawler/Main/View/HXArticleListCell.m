//
//  HXArticleListCell.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/20.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXArticleListCell.h"
#import "HXArticle.h"

@implementation HXArticleListCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

+ (float)getCellFrame:(id)msg width:(float)width {
    if ([msg isKindOfClass:[HXArticle class]]) {
        HXArticle *article = (HXArticle *)msg;
        NSString *str = article.sketch;
        CGRect frame = [str boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
        return 77 + frame.size.height - 12;
    }
    return 77;
}

@end
