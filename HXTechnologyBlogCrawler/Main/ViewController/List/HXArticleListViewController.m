//
//  HXArticleListViewController.m
//  https://github.com/huangxuan518/HXInternationalizationDemo
//
//  Created by 黄轩 on 16/7/29.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXArticleListViewController.h"
#import "HXDetailWebViewController.h"
#import "HXArticleListCell.h"
#import "HXArticle.h"
#import "HXRequestManager.h"

#import <MJRefresh/MJRefresh.h>

@interface HXArticleListViewController () <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,copy) NSString *searchText;//搜索词
@property (nonatomic,strong) NSMutableArray *dataAry;
@property (nonatomic,strong) HXRequestManager *requestManager;

@property (nonatomic,assign) NSInteger page;

@end

@implementation HXArticleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    
    self.title = [NSString stringWithFormat:@"搜索%@",_key];
    
    _page = 1;
    _dataAry = [NSMutableArray new];
    
    [self.view addSubview:self.tableView];
    
    __weak __typeof(self)weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong __typeof(self)self = weakSelf;
        //下拉刷新
        _page = 1;
        [self request:_page];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong __typeof(self)self = weakSelf;
        //加载更多
        _page++;
        [self request:_page];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)request:(NSInteger)page {
    __weak __typeof(self)weakSelf = self;
    [self.requestManager request:_key page:page complete:^(NSArray *dataAry) {
        __strong __typeof(self)self = weakSelf;
        
        if (page == 0) {
            [_dataAry removeAllObjects];
        }
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        [_dataAry addObjectsFromArray:dataAry];
        [self.tableView reloadData];
    }];
}

#pragma mark - data

- (NSArray *)dataSource {
    return _dataAry;
}

#pragma mark UITableViewDataSource/UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HXArticleListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HXArticleListCell"];
    if (!cell) {
        cell = [[HXArticleListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HXArticleListCell"];
    }
    
    HXArticle *article = self.dataSource[indexPath.row];
    
    //标题
    [cell.titleButton setTitle:article.title forState:UIControlStateNormal];
    //简述
    cell.sketchLabel.text = article.sketch;
    //作者
    [cell.nameButton setTitle:article.name forState:UIControlStateNormal];
    //时间
    cell.timeLabel.text = article.time;
    //推荐数
    cell.recommendcountLabel.text = article.recommendcount.length > 0 ? article.recommendcount : @"推荐(0)";
    //评论数
    cell.commentcountLabel.text = article.commentcount.length > 0 ? article.commentcount : @"评论(0)";
    //阅读数
    cell.readcountLabel.text = article.readcount.length > 0 ? article.readcount : @"阅读(0)";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXArticle *article = self.dataSource[indexPath.row];
    return [HXArticleListCell getCellFrame:article width:tableView.frame.size.width];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HXArticle *article = self.dataSource[indexPath.row];
    
    [self gotoDetailWebViewController:article];
}

#pragma mark - goto

/**
 *  去文章详情界面
 */
- (void)gotoDetailWebViewController:(HXArticle *)article {
    HXDetailWebViewController *vc = [HXDetailWebViewController new];
    vc.article = article;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerNib:[UINib nibWithNibName:@"HXArticleListCell" bundle:nil] forCellReuseIdentifier:@"HXArticleListCell"];
    }
    return _tableView;
}

- (HXRequestManager *)requestManager {
    if (!_requestManager) {
        _requestManager = [HXRequestManager new];
    }
    return _requestManager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
