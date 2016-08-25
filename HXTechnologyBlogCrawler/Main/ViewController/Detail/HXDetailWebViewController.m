//
//  HXDetailWebViewController.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/20.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXDetailWebViewController.h"

@interface HXDetailWebViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation HXDetailWebViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([_type isEqualToString:@"home"]) {
        self.title = _article.name;
        
        //1.创建并加载远程网页
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_article.homepage]]];
    } else if ([_type isEqualToString:@"detail"]) {
        self.title = _article.title;
        
        //1.创建并加载远程网页
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_article.url]]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
			
    
}

@end
