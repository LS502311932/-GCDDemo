//
//  ViewController.m
//  LearnGCD演示
//
//  Created by 刘帅 on 2019/11/6.
//  Copyright © 2019 刘帅. All rights reserved.
//

/**
 *核心概念：将任务添加到队列，指定任务执行方法
 *任务
    *使用block 封装
    *block 就是一个提前准备好的代码块，在需要的时候执行
 *队列
    *串行：一个接一个的调度任务
    *并发：可以同时调度多个任务
 *任务执行函数 （都需要在线程中操作）
    *同步执行：当前指令不完成，不会执行下个指令(不会到线程池中拿子线程)
    *异步执行：当前指令不完成，不会等待 继续执行下个指令(只要有任务，就会到线程池中取子线程；主队列除外！)
 *    开不开线程，取决于执行任务的函数，同步不开异步开
 *    开几条线程，取决于队列，串行一条 并发多条（异步）
 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self gcdDemo1];
//    [self gcdDemo2];
//    [self gcdDemo3];
//    [self gcdDemo4];
    [self gcdDemo6];
}
//串行队列：同步任务
//不会开启线程 顺序执行
-(void)gcdDemo1{
    /**
     1.队列 名称
     2.队列的属性 DISPATCH_QUEUE_SERIAL 标识串行
     */
    dispatch_queue_t q =dispatch_queue_create(@"lsgcd", NULL);
    
    //同步执行任务
    for (int i=0; i<10; i++) {
        dispatch_sync(q, ^{
            NSLog(@"%@ %d",[NSThread currentThread],i);
        });
    }
    
}
//串行队列 异步任务
- (void)gcdDemo2{
    /**
     1.队列 名称
     2.队列的属性 DISPATCH_QUEUE_SERIAL 标识串行
     */
    dispatch_queue_t q =dispatch_queue_create(@"lsgcd", NULL);
    
    //异步执行任务
    for (int i=0; i<10; i++) {
        NSLog(@"%d---------",i);
        dispatch_async(q, ^{
            NSLog(@"%@ %d",[NSThread currentThread],i);
        });
    }
    //主线程任务
    NSLog(@"over");
}
//并发队列 异步执行
- (void)gcdDemo3{
    /**
     1.队列 名称
     2.队列的属性 DISPATCH_QUEUE_CONCURRENT 标识并行
     */
    dispatch_queue_t q =dispatch_queue_create(@"lsgcd", DISPATCH_QUEUE_CONCURRENT);
    
    //异步执行任务
    for (int i=0; i<10; i++) {
//        NSLog(@"%d---------",i);

        dispatch_async(q, ^{
            NSLog(@"%@ %d",[NSThread currentThread],i);
        });
    }
    //主线程任务
    NSLog(@"over");
}

//并发队列 同步执行
//不会开启线程 循序执行
- (void)gcdDemo4{
    /**
     1.队列 名称
     2.队列的属性 DISPATCH_QUEUE_CONCURRENT 标识并行
     */
    dispatch_queue_t q =dispatch_queue_create(@"lsgcd", DISPATCH_QUEUE_CONCURRENT);
    
    //异步执行任务
    for (int i=0; i<10; i++) {
//        NSLog(@"%d---------",i);

        dispatch_sync(q, ^{
            NSLog(@"%@ %d",[NSThread currentThread],i);
        });
    }
    //主线程任务
    NSLog(@"over");
}

#pragma mark 同步任务
//作用：在开发中 通常将耗时操作 放在后台执行，有些任务彼此有’依赖‘关系
//例子：登录 支付 下载
- (void)gcdDemo5{
    dispatch_queue_t loginQueue =dispatch_queue_create(@"lsGCD", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(loginQueue, ^{
        NSLog(@"用户登录 %@",[NSThread currentThread]);
    });
    
    dispatch_async(loginQueue, ^{
        NSLog(@"用户支付 %@",[NSThread currentThread]);
    });
    
    dispatch_async(loginQueue, ^{
        NSLog(@"用户下载 %@",[NSThread currentThread]);
    });
}
//增强版同步任务
//可以让队列调度多个任务前 指定一个同步任务 让所有的异步w任务，等待同步任务执行完成，这就是依赖关系
//同步任务会造成一个死锁
- (void)gcdDemo6{
    //队列
    dispatch_queue_t loginQueue = dispatch_queue_create(@"lsGCD", DISPATCH_QUEUE_CONCURRENT);
    void(^task)() = ^{
        for (int i=0 ; i <10; i++) {
            NSLog(@"%d %@",i,[NSThread currentThread]);
        }
        dispatch_sync(loginQueue, ^{
            NSLog(@"用户登录 %@",[NSThread currentThread]);
        });
        
        dispatch_async(loginQueue, ^{
            NSLog(@"用户支付 %@",[NSThread currentThread]);
        });
        
        dispatch_async(loginQueue, ^{
            NSLog(@"用户下载 %@",[NSThread currentThread]);
        });
    };
    
    dispatch_async(loginQueue, task);
}
@end
