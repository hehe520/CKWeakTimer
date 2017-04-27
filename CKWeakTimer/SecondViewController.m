//
//  SecondViewController.m
//  CKWeakTimer
//
//  Created by caokun on 17/4/25.
//  Copyright © 2017年 caokun. All rights reserved.
//

#import "SecondViewController.h"
#import "CKWeakTimer.h"

// 把所有的 CKWeakTimer 字符串替换为 NSTImer，即可实验循环引用的情况。

@interface SecondViewController ()

@property (strong, nonatomic) CKWeakTimer *timer1;
@property (strong, nonatomic) CKWeakTimer *timer2;

@property (assign, nonatomic) NSInteger test;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initView];
    
    // 启动 timer1
    self.timer1 = [CKWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:true];
    
    // 启动 timer2
    self.timer2 = [CKWeakTimer scheduledTimerWithTimeInterval:0.5 repeats:true block:^(CKWeakTimer *timer) {
        NSLog(@"timer_2");
    }];
    
    
    /*
    // 第三种初始化方式
    // block 里写了 self，可以自动释放
    self.timer1 = [CKWeakTimer scheduledTimerWithTimeInterval:1 repeats:true target:self safeBlock:^(CKWeakTimer *timer) {
        // block 里写满各种 self
        NSLog(@"timer_2");
        self.test = 1;
        self.test = 2;
        self.test = 3;
        self.test = 4;
    }];
     */
}

- (void)timerAction:(NSTimer *)t {
    [NSThread sleepForTimeInterval:0.2];        // 执行 0.2 秒
    NSLog(@"timer_1");
}

- (void)dealloc {
    NSLog(@"第2页释放");
    // [super dealloc];     // arc 下不用写
}


- (void)initView {
    self.title = @"第2页";
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *b = [[UIButton alloc] init];
    b.frame = CGRectMake(40, 100, 120, 40);
    b.backgroundColor = [UIColor grayColor];
    [b setTitle:@"回第1页" forState:UIControlStateNormal];
    [b setTitle:@"回第1页" forState:UIControlStateHighlighted];
    [b addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"timer 已经启动，不关闭直接返回第1页";
    label.frame = CGRectMake(40, 160, 320, 20);
    [self.view addSubview:label];
}

- (void)buttonAction:(UIButton *)b {
    [self.navigationController popViewControllerAnimated:true];
}

@end
