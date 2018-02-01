//
//  ViewController.m
//  FSChartViewExample
//
//  Created by vcyber on 2018/1/18.
//  Copyright © 2018年 vcyber. All rights reserved.
//

#import "ViewController.h"
#import "FSTableView.h"
#import <FSChartView/FSChartView.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)FSTableView *tableView;

@property (nonatomic, strong)NSArray *titles;
@property (nonatomic, strong)NSArray *vcs;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titles = @[@"竖直柱状图", @"水平柱状图", @"折线图", @"饼状图", @"StoryBoard"];
    _vcs = @[@"FSVerticalBarViewController", @"FSHorizontalViewController", @"FSLineViewController", @"FSPieViewController", @"FSStoryBoardController"];
    
    [self tableView];
}


- (FSTableView *)tableView {
    if (!_tableView) {
        _tableView = [[FSTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
//        [_tableView setContentOffset:CGPointMake(0, 200)];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *className = self.vcs[indexPath.row];
    UIViewController *vc;
    if (indexPath.row == 4) {
        vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:className];
    }else {
        vc = [[NSClassFromString(className) alloc] init];
    }
//    vc = [[NSClassFromString(className) alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
