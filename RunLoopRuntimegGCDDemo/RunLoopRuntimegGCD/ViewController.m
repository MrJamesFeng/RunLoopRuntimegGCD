//
//  ViewController.m
//  RunLoopRuntimegGCD
//
//  Created by LDY on 17/4/26.
//  Copyright © 2017年 LDY. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSThread *thread;

@property(nonatomic,strong)UITableView *tableView;//

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    SEL testRunloopSel = NSSelectorFromString(@"testRunloop");
    NSLog(@"LINE:%d func:%s currentThread:%@",__LINE__,__func__,[NSThread currentThread]);

    /*
    // 创建观察者
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"监听到RunLoop发生改变---%zd",activity);
    });
    
    // 添加观察者到当前RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    // 释放observer，最后添加完需要释放掉
    CFRelease(observer);
    */
//    SEL testRunloopSel = @selector(testRunloop);
//    self.thread = [[NSThread alloc]initWithTarget:self selector:testRunloopSel object:nil];
//    [self.thread start];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        SEL testRunloopSel = @selector(testRunloop);
        self.thread = [[NSThread alloc]initWithTarget:self selector:testRunloopSel object:nil];
        [self.thread start];
//      [self testRunloop];
    });
    
    [self.view addSubview:self.tableView];
    
}

-(void)testRunloop{
    NSLog(@"LINE:%d func:%s currentThread:%@",__LINE__,__func__,[NSThread currentThread]);
    // 这里写任务
    NSLog(@"----run1-----");
    for (int i =0; i<100; i++) {
        NSLog(@"LINE:%d func:%s currentThread:%@",__LINE__,__func__,[NSThread currentThread]);
        [NSThread sleepForTimeInterval:1.0];
    }
    // 创建观察者
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"监听到RunLoop发生改变---%zd",activity);
    });
    
    // 添加观察者到当前RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    // 释放observer，最后添加完需要释放掉
    CFRelease(observer);
    // 添加下边两句代码，就可以开启RunLoop，之后self.thread就变成了常驻线程，可随时添加任务，并交于RunLoop处理
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSRunLoopCommonModes];//James:NSDefaultRunLoopMode 会回到主线程造成卡顿
    [[NSRunLoop currentRunLoop] run];
    
    // 测试是否开启了RunLoop，如果开启RunLoop，则来不了这里，因为RunLoop开启了循环。
    NSLog(@"未开启RunLoop");
   
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
//    [self performSelector:@selector(testRunloop)];//testRunloop 会回到主线程
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
       [self performSelector:@selector(testRunloop)];
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 200;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @"text";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"row=%ld",(long)indexPath.row];
    
    return cell;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 400)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

@end
