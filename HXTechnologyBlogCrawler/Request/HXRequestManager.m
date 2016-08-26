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

- (NSString *)requestWithBlogType:(NSString *)blogType key:(NSString *)key page:(NSInteger)page {
    NSString *urlStr;
    if ([blogType isEqualToString:@"csdn"]) {
        //CSDN博客 http://so.csdn.net/so/
        urlStr = [NSString stringWithFormat:@"http://so.csdn.net/so/search/s.do?p=%ld&q=%@&t=blog&domain=&o=&s=&u=null&l=null",(long)page,key];
    } else if ([blogType isEqualToString:@"cnblogs"]) {
        //博客园 http://zzk.cnblogs.com/s
        urlStr = [NSString stringWithFormat:@"http://zzk.cnblogs.com/s?w=%@&t=b&p=%ld",key,(long)page];
        
    } else if ([blogType isEqualToString:@"51cto"]) {
        //51CTO博客 http://so.51cto.com/
        urlStr = [NSString stringWithFormat:@"http://so.51cto.com/index.php?project=blog&keywords=%@&sort=&p=%ld",key,(long)page];
        
    } else if ([blogType isEqualToString:@"oschina"]) {
        //开源中国博客 http://www.oschina.net/search
        urlStr = [NSString stringWithFormat:@"http://www.oschina.net/search?q=%@&scope=blog&fromerr=BlURTW5c&p=%ld",key,(long)page];
    }
    return urlStr;
}

////博客类型 1.@"csdn" CSDN博客  2.@"cnblogs" 博客园 3.@"51cto" 51CTO博客 4.@"oschina" 开源中国博客
- (void)requestWithBlogType:(NSString *)blogType key:(NSString *)key page:(NSInteger)page complete:(void(^)(NSArray *dataAry,NSString *findCount))complete {
    
    NSString *urlStr = [self requestWithBlogType:blogType key:key page:page];
    
    //将网址转化为UTF8编码
    NSString *urlStringUTF8 = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStringUTF8]];
    
    __weak __typeof(self)weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               __strong __typeof(self)self = weakSelf;
                               
                               dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                   
                                   __block NSArray *a;
                                   __block NSString *s;
                                   // 处理耗时操作的代码块...
                                   if (!error) {
                                        if ([blogType isEqualToString:@"csdn"]) {
                                           //CSDN博客
                                           [self csdnDataCrawlingProcess:data complete:^(NSArray *blogDataAry, NSString *blogFindCount) {
                                               a = blogDataAry;
                                               s = blogFindCount;
                                           }];
                                        } else if ([blogType isEqualToString:@"cnblogs"]) {
                                           //博客园
                                            [self cnblogsDataCrawlingProcess:data complete:^(NSArray *blogDataAry, NSString *blogFindCount) {
                                                a = blogDataAry;
                                                s = blogFindCount;
                                            }];
                                        } else if ([blogType isEqualToString:@"51cto"]) {
                                           //51CTO博客
                                            [self ctoDataCrawlingProcess:data complete:^(NSArray *blogDataAry, NSString *blogFindCount) {
                                                a = blogDataAry;
                                                s = blogFindCount;
                                            }];
                                        } else if ([blogType isEqualToString:@"oschina"]) {
                                           //开源中国博客
                                            [self oschinaDataCrawlingProcess:data complete:^(NSArray *blogDataAry, NSString *blogFindCount) {
                                                a = blogDataAry;
                                                s = blogFindCount;
                                            }];
                                        }
                                   }
                                   
                                   //通知主线程刷新
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       //回调或者说是通知主线程刷新，
                                       NSLog(@"完成");
                                       if (complete) {
                                           complete(a,s);
                                       }
                                       
                                   });
                               });
                           }];
}

#pragma mark - 各博客数据处理

/**
 *  CSDN数据爬取处理
 *
 *  @param data <#data description#>
 *
 *  @return <#return value description#>
 */
- (void)csdnDataCrawlingProcess:(NSData *)data complete:(void(^)(NSArray *dataAry,NSString *findCount))complete {
    NSMutableArray *dataAry = [NSMutableArray new];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    
    NSArray *ary = [xpathParser searchWithXPathQuery:@"//dl[@class='search-list']"];
    
    NSArray *findAry = [xpathParser searchWithXPathQuery:@"//span[@class='page-nav']"];
    
    NSString *findCount;
    if (findAry.count > 0) {
        TFHppleElement *e = findAry[0];
        findCount = [self getsTheDataBetweenTheTwoString:e.content startStr:@"共" endStr:@"条结果"];
    }

    [ary enumerateObjectsUsingBlock:^(TFHppleElement *hppleElement, NSUInteger idx, BOOL * _Nonnull stop) {
        
        HXArticle *article = [HXArticle new];
        
        //标题
        article.title = [self hppleElement:hppleElement searchWithXPathQuery:@"//dt"];
        
        //简述
        article.sketch = [self hppleElement:hppleElement searchWithXPathQuery:@"//dd[@class='search-detail']"];
        
        //作者 日期 浏览
        NSString *str = [self hppleElement:hppleElement searchWithXPathQuery:@"//dd[@class='author-time']"];
        
        //时间
        NSArray *array = [str componentsSeparatedByString:@"   "];
        if (array.count > 2) {
            //作者
            article.name = [array[0] stringByReplacingOccurrencesOfString:@"作者：" withString:@""];
            //时间
            NSString *timeStr = [array[1] stringByReplacingOccurrencesOfString:@"日期：" withString:@""];
            article.time = [timeStr substringToIndex:10];

            array = [array[2] componentsSeparatedByString:@" "];
            if (array.count > 2) {
                //浏览次数
                article.readcount = [NSString stringWithFormat:@"%@",array[1]];
            }
        }

        //带标签
        //hppleElement.raw
        [self getLinkWithSectionHtmlCode:hppleElement.raw complete:^(NSArray *resultAry) {
            if (resultAry.count > 1) {
                article.url = resultAry[0];
                article.homepage = resultAry[1];
            }
        }];
        
        [dataAry addObject:article];
    }];
    
    if (complete) {
        complete(dataAry,findCount);
    }
}

/**
 *  博客园数据爬取处理
 *
 *  @param data <#data description#>
 *
 *  @return <#return value description#>
 */
- (void)cnblogsDataCrawlingProcess:(NSData *)data complete:(void(^)(NSArray *dataAry,NSString *findCount))complete {
    NSMutableArray *dataAry = [NSMutableArray new];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    
    NSArray *ary = [xpathParser searchWithXPathQuery:@"//div[@class='searchItem']"];
    
    NSArray *findAry = [xpathParser searchWithXPathQuery:@"//b[@id='CountOfResults']"];
    
    NSString *findCount;
    if (findAry.count > 0) {
        TFHppleElement *e = findAry[0];
        findCount = e.content;
    }
    
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
        NSString *recommendcountStr = [self hppleElement:hppleElement searchWithXPathQuery:@"//span[@class='searchItemInfo-good']"];
        article.recommendcount = [self getsTheDataBetweenTheTwoString:recommendcountStr startStr:@"(" endStr:@")"];
        
        //评论
        NSString *commentcountStr = [self hppleElement:hppleElement searchWithXPathQuery:@"//span[@class='searchItemInfo-comments']"];
        article.commentcount = [self getsTheDataBetweenTheTwoString:commentcountStr startStr:@"(" endStr:@")"];
        
        //浏览
        NSString *readcountStr = [self hppleElement:hppleElement searchWithXPathQuery:@"//span[@class='searchItemInfo-views']"];
        article.readcount = [self getsTheDataBetweenTheTwoString:readcountStr startStr:@"(" endStr:@")"];
        
        //带标签
        //hppleElement.raw
        [self getLinkWithSectionHtmlCode:hppleElement.raw complete:^(NSArray *resultAry) {
            if (resultAry.count > 1) {
                article.url = resultAry[0];
                article.homepage = resultAry[1];
            }
        }];
        
        [dataAry addObject:article];
    }];
    
    if (complete) {
        complete(dataAry,findCount);
    }
}

/**
 *  51CTO博客数据爬取处理
 *
 *  @param data <#data description#>
 *
 *  @return <#return value description#>
 */
- (void)ctoDataCrawlingProcess:(NSData *)data complete:(void(^)(NSArray *dataAry,NSString *findCount))complete {
    NSMutableArray *dataAry = [NSMutableArray new];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    
    NSArray *ary = [xpathParser searchWithXPathQuery:@"//div[@class='res-doc']"];
    
    NSArray *findAry = [xpathParser searchWithXPathQuery:@"//div[@class='fr']"];
    
    NSString *findCount;
    if (findAry.count > 0) {
        TFHppleElement *e = findAry[0];
        findCount = [self getsTheDataBetweenTheTwoString:e.content startStr:@"大约有 " endStr:@" 项符合查询结果"];
        findCount = [findCount stringByReplacingOccurrencesOfString:@"," withString:@""];
    }
    
    [ary enumerateObjectsUsingBlock:^(TFHppleElement *hppleElement, NSUInteger idx, BOOL * _Nonnull stop) {
        
        HXArticle *article = [HXArticle new];
        
        //标题
        article.title = [self hppleElement:hppleElement searchWithXPathQuery:@"//h2"];
        
        //简述
        article.sketch = [self hppleElement:hppleElement searchWithXPathQuery:@"//p"];
        
        //时间
        NSString *str = [self hppleElement:hppleElement searchWithXPathQuery:@"//ul"];
        NSArray *array = [str componentsSeparatedByString:@"\n时间:"];
        if (array.count > 1) {
            article.time = array[1];
        }
        
        //带标签
        //hppleElement.raw
        [self getLinkWithSectionHtmlCode:hppleElement.raw complete:^(NSArray *resultAry) {
            if (resultAry.count > 1) {
                article.url = resultAry[0];
                article.homepage = resultAry[1];
                
                NSArray *array = [resultAry[1] componentsSeparatedByString:@"."];
                if (array.count > 1) {
                    //作者
                    article.name = [array[0] stringByReplacingOccurrencesOfString:@"http://" withString:@""];
                }
            }
        }];
        
        [dataAry addObject:article];
    }];
    
    if (complete) {
        complete(dataAry,findCount);
    }
}

/**
 *  开源中国数据爬取处理
 *
 *  @param data <#data description#>
 *
 *  @return <#return value description#>
 */
- (void)oschinaDataCrawlingProcess:(NSData *)data complete:(void(^)(NSArray *dataAry,NSString *findCount))complete {
    NSMutableArray *dataAry = [NSMutableArray new];
    
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:data];
    
    NSArray *ary = [xpathParser searchWithXPathQuery:@"//li[@class='obj_type_3']"];
    
    NSArray *findAry = [xpathParser searchWithXPathQuery:@"//div[@id='ResultStats']"];
    
    NSString *findCount;
    if (findAry.count > 0) {
        TFHppleElement *e = findAry[0];
        findCount = [self getsTheDataBetweenTheTwoString:e.content startStr:@"最多只显示 " endStr:@" 条结果"];
    }
    
    [ary enumerateObjectsUsingBlock:^(TFHppleElement *hppleElement, NSUInteger idx, BOOL * _Nonnull stop) {
        
        HXArticle *article = [HXArticle new];
        
        //标题
        article.title = [self hppleElement:hppleElement searchWithXPathQuery:@"//a"];
        
        //简述
        article.sketch = [self hppleElement:hppleElement searchWithXPathQuery:@"//p[@class='outline']"];
        
        //时间 作者 评论 阅读
        NSString *str = [self hppleElement:hppleElement searchWithXPathQuery:@"//p[@class='date']"];
        
        NSArray *array = [str componentsSeparatedByString:@"by@"];
        
        if (array.count > 1) {
            //时间
            article.time = array[0];
            
            array = [array[1] componentsSeparatedByString:@"\n\t\t"];
            
            if (array.count > 1) {
                //作者
                article.name = array[0];
                
                array = [array[1] componentsSeparatedByString:@"评/"];
                if (array.count > 1) {
                    //评论
                    article.commentcount = [NSString stringWithFormat:@"%@",array[0]];
                    //浏览
                    article.readcount = [NSString stringWithFormat:@"%@",[array[1] stringByReplacingOccurrencesOfString:@"阅" withString:@""]];
                }
            }
        }
        
        //带标签
        //hppleElement.raw
        [self getLinkWithSectionHtmlCode:hppleElement.raw complete:^(NSArray *resultAry) {
            if (resultAry.count > 1) {
                article.url = resultAry[0];
                article.homepage = resultAry[1];
            }
        }];
        
        [dataAry addObject:article];
    }];
    
    if (complete) {
        complete(dataAry,findCount);
    }
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
 *  获取一段字符串中的所有链接
 *
 *  @param htmlCode <#htmlCode description#>
 *  @param complete <#complete description#>
 */
- (void)getLinkWithSectionHtmlCode:(NSString *)htmlCode complete:(void(^)(NSArray *resultAry))complete {
    
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
        }
    }
    
    if (complete) {
        complete(resultAry);
    }
}

/**
 *  提取指定的2段字符串之间的数据
 *
 *  @param someString 需要提取的字符串
 *  @param startStr   起点
 *  @param endStr     终点
 *
 *  @return <#return value description#>
 */
- (NSString *)getsTheDataBetweenTheTwoString:(NSString *)someString startStr:(NSString *)startStr endStr:(NSString *)endStr {
    
    if ([someString rangeOfString:startStr].location != NSNotFound) {
        
        //起点的位置
        NSRange startingPointTagRange = [someString rangeOfString:startStr];
        
        //新字符串 0)浏览(71)
        someString = [someString substringFromIndex:startingPointTagRange.location + startingPointTagRange.length];
        
        if ([someString rangeOfString:endStr].location != NSNotFound) {
            //反括号的位置
            NSRange tagRange = [someString rangeOfString:endStr];
            //反括号位置之前的部分即为我们需要提取的内容
            return [someString substringToIndex:tagRange.location];
        }
    }
    return @"";
}

@end
