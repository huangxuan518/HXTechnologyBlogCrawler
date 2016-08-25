//
//  HXHistoryListViewController.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/25.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXHistoryListViewController.h"
#import "HXSearchResultViewController.h"

@interface HXHistoryListViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataAry;

@end

@implementation HXHistoryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"搜索历史";
    
    [self.view addSubview:self.tableView];
}

#pragma mark - data

- (NSArray *)dataSource {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *ary = [userDefaults objectForKey:@"tagAry"];
    return ary;
}

#pragma mark UITableViewDataSource/UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellID"];
    }
    
    NSString *str = self.dataSource[self.dataSource.count - indexPath.row - 1];
    
    cell.textLabel.text = str;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *str = self.dataSource[self.dataSource.count - indexPath.row - 1];
    [self gotoSearchResultViewController:str];
}

#pragma mark - goto

- (void)gotoSearchResultViewController:(NSString *)key {
    HXSearchResultViewController *vc = [HXSearchResultViewController new];
    vc.key = key;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 30) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerNib:[UINib nibWithNibName:@"HXArticleListCell" bundle:nil] forCellReuseIdentifier:@"HXArticleListCell"];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
