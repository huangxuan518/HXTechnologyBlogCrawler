//
//  HXDetailWebViewController.h
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/20.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXArticle.h"

@interface HXDetailWebViewController : UIViewController

@property (strong, nonatomic) HXArticle *article;
@property (copy, nonatomic) NSString *type;

@end
