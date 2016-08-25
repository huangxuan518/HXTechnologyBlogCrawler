//
//  HXArticleListCell.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/20.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXArticleListCell.h"

@interface HXArticleListCell ()

@property (nonatomic,strong) HXArticle *article;

@end

@implementation HXArticleListCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setData:(id)data key:(NSString *)key delegate:(id)delegate {
    if ([data isKindOfClass:[HXArticle class]]) {
        _delegate = delegate;
        _article = (HXArticle *)data;
        //标题
        [self.titleButton setAttributedTitle:[self getTitleAttributedString:_article.title key:key] forState:UIControlStateNormal];
        //简述
        self.sketchLabel.attributedText = [self getContentAttributedString:_article.sketch key:key];
        //作者
        [self.nameButton setTitle:_article.name forState:UIControlStateNormal];
        //时间
        self.timeLabel.text = [NSString stringWithFormat:@"发布于 %@",_article.time];

        NSMutableString *str = [NSMutableString stringWithString:@""];
        
        //推荐数
        if (_article.recommendcount.integerValue > 0) {
            [str appendFormat:@"推荐(%@)",_article.recommendcount];
        }
        
        //评论数
        if (_article.commentcount.integerValue > 0) {
            if (_article.recommendcount.integerValue > 0) {
                [str appendString:@" "];
            }
            [str appendFormat:@"评论(%@)",_article.commentcount];
        }
        
        //阅读数
        if (_article.readcount.integerValue > 0) {
            if (_article.commentcount.integerValue > 0) {
                [str appendString:@" "];
            }
            [str appendFormat:@"阅读(%@)",_article.readcount];
        }
        
        self.countLabel.text = str;
    }
}

#pragma mark - 文字样式处理

//获取内容样式 关键字标亮
- (NSMutableAttributedString *)getContentAttributedString:(NSString *)content key:(NSString *)key {
    
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:content];
    
    NSString *copyStr = content;
    
    NSMutableString *xxstr = [NSMutableString new];
    for (int i = 0; i < key.length; i++) {
        [xxstr appendString:@"*"];
    }
    
    while ([copyStr rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        NSRange range = [copyStr rangeOfString:key options:NSCaseInsensitiveSearch];
        
        //关键字颜色
        UIColor *keyColor = [UIColor redColor];
        
        [titleStr addAttribute:NSForegroundColorAttributeName value:keyColor range:range];
        
        copyStr = [copyStr stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:xxstr];
    }
    return titleStr;
}

//获取标题样式 标题下划线 关键字标亮
- (NSMutableAttributedString *)getTitleAttributedString:(NSString *)title key:(NSString *)key {
    //标题样式
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    
    //下划线颜色
    UIColor *undlineColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:204/255.0 alpha:1.0];
    //下划线颜色和位置
    [attributedString addAttribute:NSForegroundColorAttributeName value:undlineColor range:NSMakeRange(0,title.length)];
    //下划线样式
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0,title.length)];
    
    NSString *copyStr = title;
    
    NSMutableString *xxstr = [NSMutableString new];
    for (int i = 0; i < key.length; i++) {
        [xxstr appendString:@"*"];
    }
    
    while ([copyStr rangeOfString:key options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        NSRange range = [copyStr rangeOfString:key options:NSCaseInsensitiveSearch];
        //关键字颜色
        UIColor *keyColor = [UIColor redColor];
        [attributedString addAttribute:NSForegroundColorAttributeName value:keyColor range:range];
        
        copyStr = [copyStr stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:xxstr];
    }
    
    return attributedString;
}

- (IBAction)titleButtonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(articleListCell:titleButtonAction:article:)]) {
        [_delegate articleListCell:self titleButtonAction:sender article:_article];
    }
}

- (IBAction)nameButtonAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(articleListCell:nameButtonAction:article:)]) {
        [_delegate articleListCell:self nameButtonAction:sender article:_article];
    }
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
