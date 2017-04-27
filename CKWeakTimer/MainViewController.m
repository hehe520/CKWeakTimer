//
//  ViewController.m
//  CKWeakTimer
//
//  Created by caokun on 17/4/25.
//  Copyright © 2017年 caokun. All rights reserved.
//

#import "MainViewController.h"
#import "SecondViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"第1页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *b = [[UIButton alloc] init];
    b.frame = CGRectMake(40, 100, 120, 40);
    [b setTitle:@"去第2页" forState:UIControlStateNormal];
    [b setTitle:@"去第2页" forState:UIControlStateHighlighted];
    b.backgroundColor = [UIColor grayColor];
    [b addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
}

- (void)buttonAction:(UIButton *)b {
    SecondViewController *vc = [[SecondViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

@end
