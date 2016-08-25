//
//  HXArticle.h
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/22.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXArticle : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *sketch;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *time;
@property (nonatomic,copy) NSString *recommendcount;
@property (nonatomic,copy) NSString *commentcount;
@property (nonatomic,copy) NSString *readcount;
@property (nonatomic,copy) NSString *homepage;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *findCount;

@end
