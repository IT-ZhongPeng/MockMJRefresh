//
//  secondViewController.m
//  MockMJRefresh_Example
//
//  Created by nmxy on 2020/6/9.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#import "secondViewController.h"
#import "MockMJRefresh_Example-Bridging-Header.h"

@interface secondViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation secondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *mainTB = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStyleGrouped];
    mainTB.delegate = self;
    mainTB.dataSource = self;
    mainTB.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:mainTB];
    
    
    
    
    mainTB.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [mainTB.mj_header endRefreshing];
        });

    }];
//    mainTB.mj_header.accessibilityIdentifier = @"refresh_header";
    
    [mainTB.mj_header beginRefreshing];
    
    
    mainTB.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [mainTB.mj_footer endRefreshing];
        });
    }];

    
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}



@end
