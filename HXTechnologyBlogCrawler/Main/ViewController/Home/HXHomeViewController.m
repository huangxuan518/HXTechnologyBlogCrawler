//
//  HXHomeViewController.m
//  HXTechnologyBlogCrawler
//
//  Created by 黄轩 on 16/8/22.
//  Copyright © 2016年 黄轩. All rights reserved.
//

#import "HXHomeViewController.h"
#import "HXSearchResultViewController.h"
#import "HXHistoryListViewController.h"
#import "HXHistoryCell.h"
#import "HXHistoryLastCell.h"

@interface HXHomeViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UIView *keyView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *tagAry;
@property (nonatomic,assign) float maxHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;

@end

@implementation HXHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _keyView.layer.borderWidth = 1.0;
    _keyView.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0].CGColor;
    _tableView.layer.borderWidth = 1.0;
    _tableView.layer.borderColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0].CGColor;
    [_tableView registerNib:[UINib nibWithNibName:@"HXHistoryCell" bundle:nil] forCellReuseIdentifier:@"HXHistoryCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"HXHistoryLastCell" bundle:nil] forCellReuseIdentifier:@"HXHistoryLastCell"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *ary = [userDefaults objectForKey:@"tagAry"];
    _tagAry = [NSMutableArray arrayWithArray:ary];
    
    _maxHeight = [UIScreen mainScreen].bounds.size.height - _tableView.frame.origin.y;
    
    [self changeTableViewHeight];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - data

- (NSArray *)dataSource {
    return _tagAry;
}

#pragma mark UITableViewDataSource/UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource.count > 9) {
        return 9 + 1;
    }
    return self.dataSource.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.dataSource.count || indexPath.row == 9) {
        //最后一行
        HXHistoryLastCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HXHistoryLastCell"];
        if (!cell) {
            cell = [[HXHistoryLastCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HXHistoryLastCell"];
        }
        [cell setData:nil delegate:self];
        return cell;
    } else {
        HXHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HXHistoryCell"];
        if (!cell) {
            cell = [[HXHistoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HXHistoryCell"];
        }

        NSString *str = _tagAry[self.dataSource.count - indexPath.row - 1];
        [cell setData:str delegate:self];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _tableView.hidden = YES;
    
    NSString *str = _tagAry[self.dataSource.count - indexPath.row - 1];
    
    if (str.length > 0) {
        
        [self gotoSearchResultViewController:str];
    }
}

#pragma mark - HXHistoryCellDelegate

- (void)historyCell:(HXHistoryCell *)cell deleteButtonAction:(UIButton *)sender history:(NSString *)history {
    [_tagAry removeObject:history];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_tagAry forKey:@"tagAry"];
    [userDefaults synchronize];
    [self changeTableViewHeight];
    [_tableView reloadData];
}

#pragma mark -  HXHistoryLastCellDelegate

- (void)historyLastCell:(HXHistoryLastCell *)cell deleteButtonAction:(UIButton *)sender {
    [_tagAry removeAllObjects];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_tagAry forKey:@"tagAry"];
    [userDefaults synchronize];
    [self changeTableViewHeight];
    [_tableView reloadData];
}

- (void)historyLastCell:(HXHistoryLastCell *)cell moreButtonAction:(UIButton *)sender {
    [self gotoHistoryListViewController];
}

#pragma mark - Text

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_tagAry.count > 0) {
        _tableView.hidden = NO;
    }
    return YES;
}

- (IBAction)tapButtonAction:(UITapGestureRecognizer *)sender {
    _tableView.hidden = YES;
    [self.view endEditing:YES];
}


- (void)keyboardWasShown:(NSNotification *)notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"keyBoard:%f", keyboardSize.height);  //216
    
    _maxHeight = [value CGRectValue].origin.y - _tableView.frame.origin.y;
    [self changeTableViewHeight];
}

- (void)keyboardWasHidden:(NSNotification *)notif
{
    NSDictionary *info = [notif userInfo];
    
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    NSLog(@"keyboardWasHidden keyBoard:%f", keyboardSize.height);
    
    _maxHeight = [value CGRectValue].origin.y - _tableView.frame.origin.y;
    [self changeTableViewHeight];
}

- (void)changeTableViewHeight {
    if (_tagAry.count > 0 && _keyTextField.isFirstResponder) {
        _tableView.hidden = NO;
    }
    
    if (_tagAry.count >= 9) {
        if (_maxHeight > 20*10) {
            _tableViewHeight.constant = 200;
        } else {
            _tableViewHeight.constant = _maxHeight;
        }
    } else {
        if (_maxHeight > 20*_tagAry.count) {
            _tableViewHeight.constant = 20*(_tagAry.count + 1);
        } else {
            _tableViewHeight.constant = _maxHeight;
        }
    }
}

#pragma mark - Button Action

- (IBAction)searchButtonAction:(UIButton *)sender {
    if (_keyTextField.text.length > 0) {
        if (![_tagAry containsObject:_keyTextField.text]) {
            [_tagAry addObject:_keyTextField.text];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:_tagAry forKey:@"tagAry"];
            [userDefaults synchronize];
            
            [self changeTableViewHeight];
            
            [_tableView reloadData];
        }
        [self gotoSearchResultViewController:_keyTextField.text];
    }
}

#pragma mark - goto

- (void)gotoSearchResultViewController:(NSString *)key {
    HXSearchResultViewController *vc = [HXSearchResultViewController new];
    vc.key = key;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  去历史记录页面
 */
- (void)gotoHistoryListViewController {
    HXHistoryListViewController *vc = [HXHistoryListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardDidShowNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardDidHideNotification];
}

@end
