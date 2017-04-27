//
//  CKWeakTimer.h
//  CKWeakTimer
//
//  Created by caokun on 17/4/25.
//  Copyright © 2017年 caokun. All rights reserved.
//


/* CKWeakTimer 弱引用定时器
//
// CKWeakTimer 不会强引用 target，target 被释放的时候 CKWeakTimer 自动关闭并被释放
// CKWeakTimer 线程安全
// 
// bug反馈邮箱：657668857@qq.com
*/

#import <Foundation/Foundation.h>

@class CKWeakTimer;

typedef void (^TimerAction)(CKWeakTimer *timer);

// 模仿 NSTimer 的方法，NSTimer 部分不常用的方法没有实现，实现了常用的。

@interface CKWeakTimer : NSObject

@property (strong, nonatomic) id userInfo;      // 附加信息

// 创建并自动运行
+ (CKWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

// 创建并自动运行，block 内不能写 self
+ (CKWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(TimerAction)block;

// 创建需手动调用 start 触发运行
+ (CKWeakTimer *)timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(TimerAction)block;

// 创建并自动运行，block 里面可以直接写 self，不会泄露。 target 是调用者，要传 self 进来。
// 此方法一个 controller 暂时只支持创建一个 timer，多了会循环引用，慎用，先用第二个初始化方法，待优化。。。
+ (CKWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats target:(id)aTarget safeBlock:(TimerAction)block;

// 手动触发运行，如果 repeats == true 将一直运行，如果已经在运行了，将没任何效果
- (void)start;

// 手动触发一次运行，仅一次
- (void)fire;

// 关闭 timer
- (void)invalidate;

@end
