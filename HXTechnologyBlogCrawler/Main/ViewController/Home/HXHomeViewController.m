//
//  HXHomeViewController.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/22.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXHomeViewController.h"
#import "HXArticleListViewController.h"

@interface HXHomeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation HXHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _keyTextField.layer.borderWidth = 1.0;
    _keyTextField.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0].CGColor;
    
}

- (IBAction)searchButtonAction:(UIButton *)sender {
    [self gotoArticleListViewController];
}

- (void)gotoArticleListViewController {
    HXArticleListViewController *vc = [HXArticleListViewController new];
    vc.key = _keyTextField.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
