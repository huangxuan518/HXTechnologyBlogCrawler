//
//  HXRequestManager.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/20.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXRequestManager.h"
#import "TFHpple.h"
#import "HXArticle.h"

@implementation HXRequestManager

#pragma mark - request

- (void)request:(NSString *)key page:(NSInteger)page complete:(void(^)(NSArray *dataAry))complete {
    
    NSString *urlStr = [NSString stringWithFormat:@"http://zzk.cnblogs.com/s?w=%@&t=b&p=%ld",key,(long)page];
    //将网址转化为UTF8编码
    NSString *urlStringUTF8 = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStringUTF8]];
    
    __weak __typeof(self)weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               __strong __typeof(self)self = weakSelf;
                               
                               dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                   
                                   NSMutableArray *dataAry = [NSMutableArray new];
                                   
                                   // 处理耗时操作的代码块...
                                   if (!error) {
                                       
                                       TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
                                       
                                       NSArray *ary = [xpathParser searchWithXPathQuery:@"//div[@class='searchItem']"];
                                       
                                       [ary enumerateObjectsUsingBlock:^(TFHppleElement *hppleElement, NSUInteger idx, BOOL * _Nonnull stop) {
                                           
                                           HXArticle *article = [HXArticle new];
                                           
                                           //标题
                                           article.title = [self hppleElement:hppleElement searchWithXPathQuery:@"//h3[@class='searchItemTitle']"];

                                           //简述
                                           article.sketch = [self hppleElement:hppleElement searchWithXPathQuery:@"//span[@class='searchCon']"];
                                           
                                           //作者
                                           article.name = [self hppleElement:hppleElement searchWithXPathQuery:@"//span[@class='searchItemInfo-userName']"];
                                           
                                           //时间
                                           article.time = [self hppleElement:hppleElement searchWithXPathQuery:@"//span[@class='searchItemInfo-publishDate']"];
                                           
                                           //推荐
                                           article.recommendcount = [self hppleElement:hppleElement searchWithXPathQuery:@"//span[@class='searchItemInfo-good']"];
                                           
                                           //评论
                                           article.commentcount = [self hppleElement:hppleElement searchWithXPathQuery:@"//span[@class='searchItemInfo-comments']"];
                                           
                                           //浏览
                                           article.readcount = [self hppleElement:hppleElement searchWithXPathQuery:@"//span[@class='searchItemInfo-views']"];
                                           
                                           //带标签
                                           //hppleElement.raw
                                           [self getLinkWithSectionHtmlCode:hppleElement.raw complete:^(NSString *contentUrl, NSString *authorHomeUrl) {
                                               article.url = contentUrl;
                                               article.homepage = authorHomeUrl;
                                           }];

                                           [dataAry addObject:article];
                                       }];
                                   }
                                   
                                   //通知主线程刷新
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       //回调或者说是通知主线程刷新，
                                       NSLog(@"完成");
                                       if (complete) {
                                           complete(dataAry);
                                       }
                                   });
                               });
                           }];
}

#pragma mark - 数据处理

/**
 *  根据标签获取内容
 *
 *  @param hppleElement <#hppleElement description#>
 *  @param xPathQuery   <#xPathQuery description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)hppleElement:(TFHppleElement *)hppleElement searchWithXPathQuery:(NSString *)xPathQuery{
    NSArray *ary = [hppleElement searchWithXPathQuery:xPathQuery];
    if (ary.count > 0) {
        TFHppleElement *element = ary[0];
        
        //将\r\n去掉
        NSString *str = [element.content stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        //去掉前后空格和回车符
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //去掉内容空格
        str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        return str;
    }
    return @"";
}

/**
 *  获取链接
 *
 *  @param htmlCode <#htmlCode description#>
 *  @param complete <#complete description#>
 */
- (void)getLinkWithSectionHtmlCode:(NSString *)htmlCode complete:(void(^)(NSString *contentUrl, NSString *authorHomeUrl))complete {
    
    NSMutableArray *resultAry = [NSMutableArray new];
    
    // <a target="_blank" href="http://www.cnblogs.com/wxw511518/p/4433379.html"><strong>coreData</strong></a>
    NSString *linkTag = @"href=\"";
    
    while ([htmlCode rangeOfString:linkTag options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        //linkTag 的位置
        NSRange linkTagRange = [htmlCode rangeOfString:linkTag options:NSCaseInsensitiveSearch];
        
        //新字符串 http://www.cnblogs.com/XL-Sunny/p/5783614.html" target="_blank">
        htmlCode = [htmlCode substringFromIndex:linkTagRange.location + linkTagRange.length];
        
        NSString *tag = @"\"";
        
        if ([htmlCode rangeOfString:tag].location != NSNotFound) {
            //第一个反引号的位置
            NSRange tagRange = [htmlCode rangeOfString:tag];
            //反引号位置之前的部分即为我们需要提取的链接
            NSString *result = [htmlCode substringToIndex:tagRange.location];
            
            [resultAry addObject:result];
            
            if (resultAry.count >= 2) {
                break;
            }
        }
    }
    
    if (resultAry.count >= 2) {
        if (complete) {
            complete(resultAry[0],resultAry[1]);
        }
    }
}

/**
 *  提取其中的评论数和阅读数
 *
 *  @param countString @"评论(0)阅读(71)"
 *  @param complete    <#complete description#>
 */
- (void)getCommentcountAndReadcountWithCountString:(NSString *)countString complete:(void(^)(NSString *recommendcount, NSString *readcount))complete {
    
    NSMutableArray *resultAry = [NSMutableArray new];
    
    // @"推荐(0)浏览(71)"
    NSString *startingPointTag = @"(";
    
    while ([countString rangeOfString:startingPointTag options:NSCaseInsensitiveSearch].location != NSNotFound) {
        
        //起点的位置
        NSRange startingPointTagRange = [countString rangeOfString:startingPointTag options:NSCaseInsensitiveSearch];
        
        //新字符串 0)浏览(71)
        countString = [countString substringFromIndex:startingPointTagRange.location + startingPointTagRange.length];
        
        NSString *endTag = @")";
        
        if ([countString rangeOfString:endTag].location != NSNotFound) {
            //反括号的位置
            NSRange tagRange = [countString rangeOfString:endTag];
            //反括号位置之前的部分即为我们需要提取的内容
            NSString *result = [countString substringToIndex:tagRange.location];
            
            [resultAry addObject:result];
        }
    }
    
    if (resultAry.count >= 2) {
        if (complete) {
            complete(resultAry[0],resultAry[1]);
        }
    }
    
    
}

@end
