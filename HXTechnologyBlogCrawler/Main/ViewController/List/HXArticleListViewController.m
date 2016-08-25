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
@property (nonatomic,strong) UILabel *findCountLabel;
@property (nonatomic,strong) NSMutableArray *dataAry;
@property (nonatomic,strong) HXRequestManager *requestManager;

@property (nonatomic,assign) NSInteger page;

@end

@implementation HXArticleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];

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

- (UILabel *)findCountLabel {
    if (!_findCountLabel) {
        _findCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30)];
        _findCountLabel.backgroundColor = [UIColor grayColor];
        _findCountLabel.textAlignment = NSTextAlignmentCenter;
        _findCountLabel.font = [UIFont systemFontOfSize:12];
        _findCountLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_findCountLabel];
    }
    _findCountLabel.frame = CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30);
    return _findCountLabel;
}

- (void)request:(NSInteger)page {
    __weak __typeof(self)weakSelf = self;
    [self.requestManager requestWithBlogType:_blogType key:_key page:page complete:^(NSArray *dataAry,NSString *findCount) {
        __strong __typeof(self)self = weakSelf;
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (page == 1) {
            self.findCountLabel.text = [NSString stringWithFormat:@"为您找到相关结果约%@个",findCount];
            [_dataAry removeAllObjects];
        }

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
    
    [cell setData:self.dataSource[indexPath.row] key:_key delegate:self];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HXArticle *article = self.dataSource[indexPath.row];
    return [HXArticleListCell getCellFrame:article width:tableView.frame.size.width];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma HXArticleListCellDelegate

- (void)articleListCell:(HXArticleListCell *)cell titleButtonAction:(UIButton *)sender article:(HXArticle *)article {
    [self gotoDetailWebViewController:article type:@"detail"];
}

- (void)articleListCell:(HXArticleListCell *)cell nameButtonAction:(UIButton *)sender article:(HXArticle *)article {
    [self gotoDetailWebViewController:article type:@"home"];
}

#pragma mark - goto

/**
 *  去文章详情界面
 */
- (void)gotoDetailWebViewController:(HXArticle *)article type:(NSString *)type {
    HXDetailWebViewController *vc = [HXDetailWebViewController new];
    vc.article = article;
    vc.type = type;
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
