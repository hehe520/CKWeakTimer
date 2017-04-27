//
//  CKWeakTimer.m
//  CKWeakTimer
//
//  Created by caokun on 17/4/25.
//  Copyright © 2017年 caokun. All rights reserved.
//

#import "CKWeakTimer.h"
#import <UIKit/UIKit.h>

@interface CKWeakTimer ()

@property (assign, nonatomic) NSTimeInterval ti;
@property (weak, nonatomic) id aTarget;         // weak 引用，调用者可以直接写 self
@property (assign, nonatomic) SEL aSelector;
@property (assign, nonatomic) BOOL isRepeat;
@property (assign, nonatomic) BOOL isAutorun;
@property (assign, nonatomic) BOOL isRun;
@property (assign, nonatomic) BOOL isSafeBlock;
@property (strong, nonatomic) TimerAction action;   // strong, 调用者 block 里面不能写 self。
@property (strong, nonatomic) dispatch_queue_t timerQueue;      // timer 操作
@property (strong, nonatomic) dispatch_queue_t runQueue;        // aSelector 操作
@property (assign, nonatomic) CFTimeInterval s, t, a;           // 计时用

@end

@implementation CKWeakTimer

- (instancetype)init {
    if (self = [super init]) {
        self.ti = 1;
        self.aTarget = nil;
        self.aSelector = NULL;
        self.userInfo = nil;
        self.isRepeat = false;
        self.isAutorun = false;
        self.isRun = false;
        self.isSafeBlock = false;
        self.action = nil;
    }
    return self;
}

- (instancetype)initWithTi:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo autorun:(BOOL)autorun isSafeBlock:(BOOL)safe block:(TimerAction)block {
    if (self = [super init]) {
        self.ti = ti;
        self.aTarget = aTarget;
        self.aSelector = aSelector;
        self.userInfo = userInfo;
        self.isRepeat = yesOrNo;
        self.isAutorun = autorun;
        self.isRun = false;
        self.isSafeBlock = safe;
        self.action = block;
    }
    return self;
}

- (dispatch_queue_t)timerQueue {
    if (_timerQueue == nil) {
        _timerQueue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL);
    }
    return _timerQueue;
}

- (dispatch_queue_t)runQueue {
    if (_runQueue == nil) {
        _runQueue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL);  // 模仿 NStimer 串行
    }
    return _runQueue;
}

// 创建并自动运行
+ (CKWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    CKWeakTimer *timer = [[CKWeakTimer alloc] initWithTi:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo autorun:true isSafeBlock:false block:nil];
    [timer start];
    
    return timer;
}

// 创建并自动运行
+ (CKWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(TimerAction)block {
    CKWeakTimer *timer = [[CKWeakTimer alloc] initWithTi:interval target:nil selector:NULL userInfo:nil repeats:repeats autorun:true isSafeBlock:false block:block];
    [timer start];
    
    return timer;
}

// 创建需手动触发运行
+ (CKWeakTimer *)timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(TimerAction)block {
    CKWeakTimer *timer = [[CKWeakTimer alloc] initWithTi:interval target:nil selector:NULL userInfo:nil repeats:repeats autorun:false isSafeBlock:false block:block];
    
    return timer;
}

// 创建并自动运行，block 里面可以直接写 self，不会泄露。
+ (CKWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats target:(id)aTarget safeBlock:(TimerAction)block {
    CKWeakTimer *timer = [[CKWeakTimer alloc] initWithTi:interval target:aTarget selector:NULL userInfo:nil repeats:repeats autorun:true isSafeBlock:true block:block];
    [timer start];
    
    return timer;
}

// 手动触发运行，如果 repeats == true 将一直运行，如果已经在运行了，将没任何效果
- (void)start {
    dispatch_async(self.timerQueue, ^{
        if (self.isRun == true) {
            return ;
        }
        self.isRun = true;
        
        __weak typeof(self) ws = self;
        dispatch_async(self.runQueue, ^{
            [NSThread sleepForTimeInterval:_ti];    // 模仿 NSTimer 首次等 ti 秒再执行
            [ws loop];
        });
    });
}

// 在 runQueue 中循环调用 target 方法
- (void)loop {
    _s = CACurrentMediaTime();
    [self runOnce];
    _t = CACurrentMediaTime();
    _a = _t - _s;
    
    // 如果 runQnce 里面的方法超过了 ti 时间，将继续等待 ti 再执行。
    // 如果没超过就等待 ti - (t - s) 后执行
    if (_a < _ti) {
        _a = _ti - _a;
    } else {
        _a = _ti;
    }
    
    if (_isRepeat) {
        [NSThread sleepForTimeInterval:_a];
        __weak typeof(self) ws = self;
        
        // dispatch_async 中调 loop 不会产生递归调用
        // dispatch_async 是在队列中添加一个任务，由 GCD 去回调 [ws loop]
        dispatch_async(self.runQueue, ^{
            [ws loop];
        });
    } else {
        _isRun = false;
    }
}

// 执行 target
- (void)runOnce {
    if (self.aTarget != nil && _isSafeBlock == false) {
        if (self.aSelector != NULL) {
            if ([self.aTarget respondsToSelector:self.aSelector]) {
                // aSelector 返回值 ARC 不知道标记为 assgin 还是 strong
                //[self.aTarget performSelector:self.aSelector withObject:self];
                
                // 用函数指针调用
                IMP imp = [self.aTarget methodForSelector:self.aSelector];
                void (*func)(id obj, SEL sel, CKWeakTimer *t) = (void *)imp;
                func(self.aTarget, self.aSelector, self);
                
            } else {
                [self invalidate];
                NSLog(@"CKWeakTimer : unrecognized selector sent to instance!");
            }
        } else {
            [self invalidate];
            NSLog(@"CKWeakTimer : selector not found!");
        }
    } else if (self.action != nil) {
        // 使不使用 safe block
        if (_isSafeBlock) {
            if (self.aTarget == nil) {
                [self invalidate];
                self.action = nil;
                NSLog(@"CKWeakTimer : target not found!");
            } else {
                long count = CFGetRetainCount((__bridge CFTypeRef)self.aTarget);
                NSLog(@"--- count %ld", count);
                if (count <= 2) {
                    [self invalidate];
                    self.action = nil;
                    // target 的 RetainCount == 2，说明 block 强引用他，timer 弱引用他
                    // 那么释放 block，手动打破循环。
                    // 循环图：target -> timer -> block -> target，打破一条边即可
                } else {
                    self.action(self);
                }
            }
        } else {
            self.action(self);
        }
    } else {
        // 关闭 timer
        [self invalidate];
        NSLog(@"CKWeakTimer : selector and block not found!");
    }
}

// 手动触发一次运行，仅一次
- (void)fire {
    __weak typeof(self) ws = self;
    dispatch_async(self.runQueue, ^{
        [ws runOnce];
    });
}

// 关闭 timer
- (void)invalidate {
    __weak typeof(self) ws = self;
    dispatch_async(self.timerQueue, ^{
        ws.isRepeat = false;
    });
}

- (void)dealloc {
    NSLog(@"timer 释放");
}

@end

