//
//  HXSearchResultViewController.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/24.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXSearchResultViewController.h"
#import "HXArticleListViewController.h"

@interface HXSearchResultViewController ()

@property (nonatomic,strong) HXArticleListViewController *csdnVc; //CSDN
@property (nonatomic,strong) HXArticleListViewController *cnblogsVc; //博客园
@property (nonatomic,strong) HXArticleListViewController *ctoVc; //51CTO
@property (nonatomic,strong) HXArticleListViewController *oschinaVc; //开源中国

@property (nonatomic ,strong) UIViewController *currentVC; //当前Vc

@end

@implementation HXSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    
    self.title = [NSString stringWithFormat:@"搜索\"%@\"相关结果",_key];
    
    [self initSegmentedControl];
    [self addSubControllers];
}

#pragma mark -

- (void)initSegmentedControl
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 50)];
    view.backgroundColor = [UIColor whiteColor];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"CSDN",@"博客园",@"51CTO",@"开源中国"]];
    segmentedControl.frame = CGRectMake(10, 10,self.view.frame.size.width - 20, 30.0);
    segmentedControl.selectedSegmentIndex = 0;
    //设置分段控件点击相应事件
    [segmentedControl addTarget:self action:@selector(segmentedControlButtonAction:)forControlEvents:UIControlEventValueChanged];
    
    [view addSubview:segmentedControl];
    
    [self.view addSubview:view];
}

- (void)segmentedControlButtonAction:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    
    //  点击处于当前页面的按钮,直接跳出
    if ((self.currentVC == _csdnVc && index == 0) || (self.currentVC == _cnblogsVc && index == 1) || (self.currentVC == _ctoVc && index == 2) || (self.currentVC == _oschinaVc && index == 3)) {
        return;
    } else {

        switch (index)
        {
            case 0:
                [self replaceController:self.currentVC newController:_csdnVc];
                break;
                
            case 1:
                [self replaceController:self.currentVC newController:_cnblogsVc];
                break;
                
            case 2:
                [self replaceController:self.currentVC newController:_ctoVc];
                break;
                
            case 3:
                [self replaceController:self.currentVC newController:_oschinaVc];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - privatemethods

- (void)addSubControllers {
    _csdnVc = [HXArticleListViewController new];
    _csdnVc.view.frame = CGRectMake(0, 114, self.view.frame.size.width, self.view.frame.size.height - 114);
    _csdnVc.key = _key;
    _csdnVc.blogType = @"csdn";
    [self addChildViewController:_csdnVc];
    

    _cnblogsVc = [HXArticleListViewController new];
    _cnblogsVc.view.frame = CGRectMake(0, 114, self.view.frame.size.width, self.view.frame.size.height - 114);
    _cnblogsVc.key = _key;
    _cnblogsVc.blogType = @"cnblogs";
    [self addChildViewController:_cnblogsVc];

    _ctoVc = [HXArticleListViewController new];
    _ctoVc.view.frame = CGRectMake(0, 114, self.view.frame.size.width, self.view.frame.size.height - 114);
    _ctoVc.key = _key;
    _ctoVc.blogType = @"51cto";
    [self addChildViewController:_ctoVc];

    _oschinaVc = [HXArticleListViewController new];
    _oschinaVc.view.frame = CGRectMake(0, 114, self.view.frame.size.width, self.view.frame.size.height - 114);
    _oschinaVc.key = _key;
    _oschinaVc.blogType = @"oschina";
    [self addChildViewController:_oschinaVc];

    //  默认,第一个视图(你会发现,全程就这一个用了addSubview)
    [self.view addSubview:_csdnVc.view];

    self.currentVC = _csdnVc;
}

//  切换各个标签内容
- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    /**
     *            着重介绍一下它
     *  transitionFromViewController:toViewController:duration:options:animations:completion:
     *  fromViewController      当前显示在父视图控制器中的子视图控制器
     *  toViewController        将要显示的姿势图控制器
     *  duration                动画时间(这个属性,old friend 了 O(∩_∩)O)
     *  options                 动画效果(渐变,从下往上等等,具体查看API)
     *  animations              转换过程中得动画
     *  completion              转换完成
     */
    [self transitionFromViewController:oldController
                      toViewController:newController
                              duration:0
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                // NOPS；
                            }
                            completion:^(BOOL finished) {
                                if (finished) {
                                    self.currentVC = newController;
                                } else {
                                    self.currentVC = oldController;
                                }
                            }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
