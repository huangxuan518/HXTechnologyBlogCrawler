//
//  HXArticleListViewController.h
//  https://github.com/huangxuan518/HXInternationalizationDemo
//
//  Created by 黄轩 on 16/7/29.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXArticleListViewController : UIViewController

@property (nonatomic,copy) NSString *key; //搜索关键字
@property (nonatomic,copy) NSString *blogType; //博客类型 1.@"csdn" CSDN博客  2.@"cnblogs" 博客园 3.@"51cto" 51CTO博客 4.@"oschina" 开源中国博客

@end
