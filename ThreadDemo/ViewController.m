//
//  ViewController.m
//  ThreadDemo
//
//  Created by fangtingting on 2021/5/8.
//

#import "ViewController.h"
#import "UIImageView+webCach.h"
#import "OperationTest.h"
#import <pthread/pthread.h>
#import <semaphore.h>
#import <libkern/OSAtomic.h>
#import <os/lock.h>
@interface ViewController ()

@property (nonatomic, assign) int totalCount;
@property (nonatomic, assign) int restCount;
@property (nonatomic, assign) pthread_mutex_t lock;
@property (nonatomic, assign) NSInteger condition_value;
@property (nonatomic, strong) NSMutableArray *mulArray;
@property (nonatomic, strong) dispatch_queue_t arrayQueue;

@property (nonatomic, strong) dispatch_queue_t trainQueue;
@property (nonatomic, strong) dispatch_queue_t train2Queue;

@property (nonatomic, assign) pthread_mutex_t mutexLock;


@property (nonatomic, strong) dispatch_queue_t dicQueue;
@property (nonatomic, strong) NSMutableDictionary *mulDic;
@end
  

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.arrayQueue = dispatch_queue_create("NSMutableArrayQueue", DISPATCH_QUEUE_CONCURRENT);
    self.mulArray = [NSMutableArray array];
    
    self.dicQueue = dispatch_queue_create("NSDicQueue", DISPATCH_QUEUE_CONCURRENT);
    self.mulDic = [NSMutableDictionary dictionary];
//    [self threadTest];
   
//    [self useGCDTest];
    
//    [self buyTicket];
//    [self ascynImage];
    
//    [self useInvocationOperation];
//    [self useNSBlockOperation];
    
//    [self testOperation];
//    [self testOperationQueue];
//    [self testOperationQueueWithBlock];
//    [self testMaxConcurrentOperationCount];
//    [self testAddDependency];
    
//    [self testBarrier];
    
//    [self testbarrier];
//    self.mulArray = [NSMutableArray arrayWithObjects:@"one",@"two",@"three",nil];
//
//    [self arrayFind:1];
//    [self arrayInsert:1 str:@"111"];
//    [self arrayInsert:1 str:@"222"];
//    [self arrayFind:1];
//    [self arrayFind:2];
//    [self arrayInsert:1 str:@"234"];
    
//    [self ticket];
    
//    dispatch_async(_arrayQueue, ^{
//        for (int i =0;i<1000;i++) {
//            [self arrayInsert:i str:[NSString stringWithFormat:@"%d",i]];
//            NSLog(@"===1===%@",[NSThread currentThread]);
//        };
//
//        NSLog(@"test");
////    });
//
//
//    dispatch_async(_arrayQueue, ^{
//        for (int j =0;j<200;j++) {
//            NSLog(@"====2====");
//            [self arrayDelete:j];
//        }
//
//        NSLog(@"test2");
//    });
//
//    dispatch_async(_arrayQueue, ^{
//        [self.mulArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"====3====");
//        }];
////        for (int i =0;i<self.mulArray.count;i++) {
////            NSLog(@"===3===%@",[self.mulArray objectAtIndex:i]);
////            NSLog(@"===3===%@",[NSThread currentThread]);
////        };
//
//        NSLog(@"test3");
//    });
    
    
    dispatch_async(_dicQueue, ^{
        for (int i=0;i<1000;i++) {
            [self.mulDic setValue:[NSString stringWithFormat:@"%d",i] forKey:[NSString stringWithFormat:@"%d",i]];
            NSLog(@"===1===%@",[NSThread currentThread]);
        }
        NSLog(@"Dictest");
    });
    
    
    dispatch_async(_dicQueue, ^{
        for (int i=0;i<1000;i++) {
            [self.mulDic setValue:[NSString stringWithFormat:@"%d",i] forKey:[NSString stringWithFormat:@"%d",i]];
            NSLog(@"===2===%@",[NSThread currentThread]);
            for (int j=0;j<10;j++) {
                [self.mulDic removeObjectForKey:[NSString stringWithFormat:@"%d",j]];
            }
        }
        NSLog(@"Dictest2");
    });
    
}
- (void)ticket {
    self.trainQueue = dispatch_queue_create("trainQueue", DISPATCH_QUEUE_CONCURRENT);
    
    self.train2Queue = dispatch_queue_create("trainQueue_2", DISPATCH_QUEUE_CONCURRENT);
    
    self.totalCount = 10;
   
    pthread_mutex_init(&_mutexLock, NULL);
    
    dispatch_async(self.trainQueue, ^{
        //20人
        for (int i=0;i<20;i++) {
            if (self.totalCount == 0) {
                NSLog(@"%@===%@车站没有票了",[NSThread currentThread], @"trainQueue");
                break;
            }
            //随机去同一个车站做不同的事情
            int count = arc4random() % 2 + 1;
            if (count == 1) {
                [self seeTicket:self.trainQueue];
            }
            else {
                [self buyTicket:self.trainQueue];
            }
        }
    });
    
    dispatch_async(self.trainQueue, ^{
        //20人
        for (int i=0;i<10;i++) {
            if (self.totalCount == 0) {
                NSLog(@"%@===%@车站没有票了",[NSThread currentThread], @"trainQueue_2");
                break;
            }
            //随机去同一个车站敢不同的事情
            int count = arc4random() % 2 + 1;
            if (count == 1) {
                [self seeTicket:self.train2Queue];
            }
            else {
                [self buyTicket:self.train2Queue];
            }
        }
    });
}

- (void)seeTicket:(dispatch_queue_t)queue {
    if (self.totalCount > 0) {
        NSString *label = [self queueName:queue];
        NSLog(@"%@===%@车站还有：%d张票",[NSThread currentThread], label, self.totalCount);
    }
}

- (void)buyTicket:(dispatch_queue_t)queue {
    
    int count = arc4random() % 3 + 1;
    NSString *label = [self queueName:queue];
    
    if (self.totalCount > 0) {
        pthread_mutex_lock(&_mutexLock);
        int restTicket = self.totalCount - count;
        pthread_mutex_unlock(&_mutexLock);
        if (restTicket > 0) {
            self.totalCount = restTicket;
            NSLog(@"%@===%@售出%ld，余票：%d张",[NSThread currentThread], label, (long)count, self.totalCount);
        }
        else {
            NSLog(@"%@===%@只剩：%d张",[NSThread currentThread], label, self.totalCount);
        }
    }
    
}

- (NSString *)queueName:(dispatch_queue_t)queue {
    const char *queueLabel = dispatch_queue_get_label(queue);
    NSString *label = [NSString stringWithUTF8String:queueLabel];
    return label;
}

- (void)arrayFind:(NSInteger)index {
//    dispatch_async(_arrayQueue, ^{
        NSString *str = self.mulArray[index];
        NSLog(@"%@===find == %@",[NSThread currentThread],str);
//    });
}

- (void)arrayInsert:(NSInteger)index str:(NSString *)str{
    
//    dispatch_barrier_async(_arrayQueue, ^{
        [self.mulArray insertObject:str atIndex:index];
//        NSLog(@"%@===insert == %@",[NSThread currentThread],self.mulArray);
//    });
    
}
- (void)arrayDelete:(NSInteger)index {
//    dispatch_barrier_async(_arrayQueue, ^{
        [self.mulArray removeObjectAtIndex:index];
//        NSLog(@"%@===delete == %@",[NSThread currentThread],self.mulArray);
//    });
}

- (void)arrayReplace:(NSInteger)index str:(NSString *)str {
    dispatch_barrier_async(_arrayQueue, ^{
        [self.mulArray replaceObjectAtIndex:index withObject:str];
        NSLog(@"%@===replace == %@",[NSThread currentThread],self.mulArray);
    });
}




- (void)testConditionLock {
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1]; // 初始化，设置condition=1
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [lock lockWhenCondition:1]; // 当condition=1时 获取锁成功 否则等待（但是首次使用lockWhenCondition时condition不对时也能获取锁成功）
        
        NSLog(@"%@===A===start",[NSThread currentThread]);
        sleep(2);
        NSLog(@"%@===A===end",[NSThread currentThread]);
        
        // unlock根据不同的条件 控制对应的线程
        [lock unlockWithCondition:2]; // 解锁，同时设置condition=2并signal；
//        [lock unlockWithCondition:3];
    }];
    
    [queue addOperationWithBlock:^{
        [lock lockWhenCondition:2];
        
        NSLog(@"%@===B===start",[NSThread currentThread]);
        sleep(1);
        NSLog(@"%@===B===end",[NSThread currentThread]);
        
        [lock unlock];
    }];
    
    [queue addOperationWithBlock:^{
        [lock lockWhenCondition:3];
        
        NSLog(@"%@===C===start",[NSThread currentThread]);
        sleep(1);
        NSLog(@"%@===C===end",[NSThread currentThread]);
        
        [lock unlock];
    }];
}

- (void)testbarrier {
    dispatch_queue_t queue = dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
       
       dispatch_async(queue, ^{
           int count = arc4random() % 3 + 1;
           sleep(count);
           NSLog(@"%@===TaskA sleep==%d",[NSThread currentThread], count);
       });
       dispatch_async(queue, ^{
           int count = arc4random() % 3 + 1;
           sleep(count);
           NSLog(@"%@===TaskB sleep==%d",[NSThread currentThread], count);
       });
       
       // async不会阻塞当前线程（主线程）
//       dispatch_barrier_async(queue, ^{
//           NSLog(@"%@===Barrier",[NSThread currentThread]);
//       });
       // sync会阻塞当前队列（主队列）
       dispatch_barrier_sync(queue, ^{
           NSLog(@"%@===Barrier",[NSThread currentThread]);
       });
       
       dispatch_async(queue, ^{
           int count = arc4random() % 3 + 1;
           sleep(count);
           NSLog(@"%@===TaskC sleep==%d",[NSThread currentThread], count);
       });
       dispatch_async(queue, ^{
           int count = arc4random() % 3 + 1;
           sleep(count);
           NSLog(@"%@===TaskD sleep==%d",[NSThread currentThread], count);
       });

}

- (void)testGroup {
    // group必须使用自己创建的并发队列 使用global全局队列无效
       dispatch_queue_t queue = dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
   //    dispatch_queue_t queue = dispatch_get_global_queue(0, 0); xxx
       
       dispatch_group_t group = dispatch_group_create();
       
       dispatch_group_async(group, queue, ^{
           sleep(1);
           NSLog(@"%@===TaskA",[NSThread currentThread]);
       });
       dispatch_group_async(group, queue, ^{
           sleep(1);
           NSLog(@"%@===TaskB",[NSThread currentThread]);
       });
       
       dispatch_group_notify(group, queue, ^{
           NSLog(@"%@===TaskC",[NSThread currentThread]);
       });
   //    dispatch_async(queue, ^{
   //        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC))); // 可以设置等待的超时时间
   //        NSLog(@"%@===TaskC",[NSThread currentThread]);
   //    });
}

- (void)testSpinLock {
    
//    __block OSSpinLock lock = OS_SPINLOCK_INIT;
//
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [queue addOperationWithBlock:^{
//        OSSpinLockLock(&lock);
//        NSLog(@"%@===write===start",[NSThread currentThread]);
//        sleep(3);
//        NSLog(@"%@===write===end",[NSThread currentThread]);
//        OSSpinLockUnlock(&lock);
//    }];
//    [queue addOperationWithBlock:^{
//        OSSpinLockLock(&lock);
//        NSLog(@"%@===read===start",[NSThread currentThread]);
//        sleep(2);
//        NSLog(@"%@===read===end",[NSThread currentThread]);
//        OSSpinLockUnlock(&lock);
//    }];
    __block os_unfair_lock lock = OS_UNFAIR_LOCK_INIT;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        os_unfair_lock_lock(&lock);
        NSLog(@"%@===write===start",[NSThread currentThread]);
        sleep(3);
        NSLog(@"%@===write===end",[NSThread currentThread]);
        os_unfair_lock_unlock(&lock);
    }];
    
    [queue addOperationWithBlock:^{
        os_unfair_lock_lock(&lock);
        NSLog(@"%@===read===start",[NSThread currentThread]);
        sleep(2);
        NSLog(@"%@===read===end",[NSThread currentThread]);
        os_unfair_lock_unlock(&lock);
    }];
    
}


- (void)testSemaphore2 {
    sem_t *sem = sem_open("semCount", O_CREAT, 0644, 3);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    for (int i=0;i<9;i++) {
        [queue addOperationWithBlock:^{
            sem_wait(sem);
            NSLog(@"%@===write===start",[NSThread currentThread]);
            sleep(3);
            NSLog(@"%@===write===end",[NSThread currentThread]);
            sem_post(sem);
        }];
    }
    
}

- (void)testSemaphore {
    // 创建 原型sem_t *sem_open(const char *name,int oflag,mode_t mode,unsigned int value);
    // name 信号的外部名字
    // oflag 选择创建或打开一个现有的信号灯
    // mode 权限位
    // value 信号初始值
    sem_t *sem = sem_open("semname", O_CREAT, 0644, 1);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        sem_wait(sem); // 首先判断信号量value 如果=0则等待，否则value-1并正常往下走
        NSLog(@"%@===write===start",[NSThread currentThread]);
        sleep(3);
        NSLog(@"%@===write===end",[NSThread currentThread]);
        sem_post(sem); // 执行完发送信号，value+1
    }];
    
    [queue addOperationWithBlock:^{
        sem_wait(sem);
        NSLog(@"%@===read===start",[NSThread currentThread]);
        sleep(2);
        NSLog(@"%@===read===end",[NSThread currentThread]);
        sem_post(sem);
    }];
    
    
}

- (void)condThread {
    // 1.静态初始化
    static pthread_cond_t cond_lock = PTHREAD_COND_INITIALIZER;
    static pthread_mutex_t mutex_lock = PTHREAD_MUTEX_INITIALIZER; // 需要配合mutex互斥锁使用
    
    // 2.动态创建
    static pthread_cond_t cond_lock1;
    pthread_cond_init(&cond_lock1, NULL);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        pthread_mutex_lock(&mutex_lock);
        while (self.condition_value <= 0) { // 条件成立则暂时解锁并等待
            pthread_cond_wait(&cond_lock, &mutex_lock);
        }
        
        NSLog(@"%@===read===start",[NSThread currentThread]);
        sleep(2);
        NSLog(@"%@===read===end",[NSThread currentThread]);
        pthread_mutex_unlock(&mutex_lock);
    }];
    
    [queue addOperationWithBlock:^{
        pthread_mutex_lock(&mutex_lock);
        NSLog(@"%@===write===start",[NSThread currentThread]);
        sleep(3);
        self.condition_value = 1; // 一定要更改条件 否则上面read线程条件成立又会wait
        NSLog(@"%@===write===end",[NSThread currentThread]);
        
        pthread_cond_signal(&cond_lock); // 传递信号给等待的线程 而且是在解锁前
        pthread_mutex_unlock(&mutex_lock);
    }];
}

static pthread_t thread1;
static pthread_t thread2;

void * writeFunc(void *args) {
    NSLog(@"%u===write===start",(unsigned int)pthread_self());
    sleep(3);
    NSLog(@"%u===write===end",(unsigned int)pthread_self());
    pthread_exit(NULL);
    return NULL;
}

void* readFunc(void *args) {
    pthread_join(thread1, NULL);
    NSLog(@"%u===read===start",(unsigned int)pthread_self());
    sleep(2);
    NSLog(@"%u===read===end",(unsigned int)pthread_self());
    return NULL;
}

- (void)joinPthread {
    pthread_create(&thread1, NULL, writeFunc, NULL);
    pthread_create(&thread2, NULL, readFunc, NULL);
}

- (void)readWriteLock {
    // 两种初始化方式
    // 1.静态初始化
    static pthread_rwlock_t lock = PTHREAD_RWLOCK_INITIALIZER;
    
    // 2.动态创建
    static pthread_rwlock_t lock1;
    pthread_rwlock_init(&lock1, NULL);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    for (int i=0;i<2;i++) {
        [queue addOperationWithBlock:^{
            pthread_rwlock_wrlock(&lock);
            NSLog(@"%@===write===start",[NSThread currentThread]);
            sleep(3);
            NSLog(@"%@===write===end",[NSThread currentThread]);
            pthread_rwlock_unlock(&lock);
        }];
    }
    for (int i=0;i<2;i++) {
        [queue addOperationWithBlock:^{
            pthread_rwlock_rdlock(&lock);
            NSLog(@"%@===read===start",[NSThread currentThread]);
            sleep(2);
            NSLog(@"%@===read===end",[NSThread currentThread]);
            pthread_rwlock_unlock(&lock);
        }];
    }
}

- (void)synchronizedTest {
    pthread_mutexattr_t att;
    pthread_mutexattr_init(&att);
    // PTHREAD_MUTEX_NORMAL普通互斥锁 PTHREAD_MUTEX_RECURSIVE递归锁
    pthread_mutexattr_settype(&att, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_lock, &att);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [self recursiveTest:3]; // 递归调用
    }];
}

// 递归方法
- (void)recursiveTest:(NSInteger)value {
    pthread_mutex_lock(&_lock);
    
    if (value > 0) {
        NSLog(@"%@===start",[NSThread currentThread]);
        sleep(1);
        NSLog(@"%@===end",[NSThread currentThread]);
        [self recursiveTest:value-1];
    }
    
    pthread_mutex_unlock(&_lock);
}

- (void)testPthreadMutex {
    //两种初始化的方式
    //1、静态初始化
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    
    //2、动态创建
    pthread_mutex_t lock1;
    // 可以根据需要配置pthread_mutexattr NULL默认为互斥锁
    pthread_mutex_init(&lock1, NULL);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        pthread_mutex_lock(&lock);//加锁
        NSLog(@"%@===write===start",[NSThread currentThread]);
        sleep(3);
        NSLog(@"%@===write===end",[NSThread currentThread]);
        pthread_mutex_unlock(&lock); // 解锁
    }];
    
    [queue addOperationWithBlock:^{
        pthread_mutex_lock(&lock);//加锁
        NSLog(@"%@===read===start",[NSThread currentThread]);
        sleep(2);
        NSLog(@"%@===read===end",[NSThread currentThread]);
        pthread_mutex_unlock(&lock); // 解锁
    }];
}

- (void)testBarrier {
    // 并发队列
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    
    // 异步执行
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"栅栏：并发异步1   %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"栅栏：并发异步2   %@",[NSThread currentThread]);
        }
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"------------barrier------------%@", [NSThread currentThread]);
        NSLog(@"******* 并发异步执行，但是34一定在12后面 *********");
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"栅栏：并发异步3   %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"栅栏：并发异步4   %@",[NSThread currentThread]);
        }
    });
}

- (void)testAddDependency {

    // 并发队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 操作1
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"operation1======%@", [NSThread  currentThread]);
        }
    }];

    // 操作2
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"****operation2依赖于operation1，只有当operation1执行完毕，operation2才会执行****");
        for (int i = 0; i < 3; i++) {
            NSLog(@"operation2======%@", [NSThread  currentThread]);
        }
    }];

    // 使操作2依赖于操作1
    [operation2 addDependency:operation1];
    // 把操作加入队列
    [queue addOperation:operation1];
    [queue addOperation:operation2];
}

- (void)testMaxConcurrentOperationCount {
    // 创建队列，默认并发
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // 最大并发数为1，串行
//    queue.maxConcurrentOperationCount = 1;

    // 最大并发数为2，并发
    queue.maxConcurrentOperationCount = 2;


    // 添加操作到队列
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"addOperationWithBlock把任务添加到队列1======%@", [NSThread currentThread]);
        }
    }];
    // 添加操作到队列
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"addOperationWithBlock把任务添加到队列2======%@", [NSThread currentThread]);
        }
    }];

    // 添加操作到队列
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"addOperationWithBlock把任务添加到队列3======%@", [NSThread currentThread]);
        }
    }];
}

- (void)testOperationQueueWithBlock {
    //创建队列，默认并发
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //添加操作到队列
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"addOperationWithBlock把任务添加到队列======%@", [NSThread currentThread]);
        }
    }];
}

- (void)testOperationQueue {
    //创建队列，默认并发
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //创建操作，NSInvocationOperation
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queueOperationAddOperation) object:nil];
    
    // 创建操作，NSBlockOperation
    NSBlockOperation *bp = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
                    NSLog(@"NSBlockOperation======%@", [NSThread currentThread]);
                }
    }];
    
    [queue addOperation:op];
    [queue addOperation:bp];
    
}

- (void)queueOperationAddOperation {
    NSLog(@"invocationOperation====%@", [NSThread currentThread]);
}

- (void)testOperation {
    OperationTest *test = [[OperationTest alloc] init];
    [test start];
}

- (void)useNSBlockOperation {
    NSBlockOperation *bp = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSBlockOperation主任务---%@",[NSThread currentThread]);
    }];
    
    [bp addExecutionBlock:^{
        NSLog(@"addExecutionBlock方法添加任务1========%@", [NSThread currentThread]);
    }];
    
    [bp addExecutionBlock:^{
        NSLog(@"addExecutionBlock方法添加任务2========%@", [NSThread currentThread]);
    }];
    
    [bp addExecutionBlock:^{
        NSLog(@"addExecutionBlock方法添加任务3========%@", [NSThread currentThread]);
    }];
    
    [bp start];
}

- (void)useInvocationOperation {
    // 1.创建 NSInvocationOperation 对象
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    // 2.调用 start 方法开始执行操作
    [op start];
}

- (void)task1{
    for (int i=0;i<3;i++) {
        NSLog(@"NSInvocationOperation---%@",[NSThread currentThread]);
    }
}

- (void)ascynImage {
    //异步加载图片
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(60, 20, 200, 120)];
    imageView.backgroundColor=[UIColor greenColor];
    [imageView setImageUrl:[NSURL URLWithString:@"https://live.dz11.com/upload/avatar/default/11_middle.jpg"]];
    
    UIImageView *imageView2=[[UIImageView alloc]initWithFrame:CGRectMake(60, 180, 200, 120)];
    imageView2.backgroundColor=[UIColor greenColor];
    
    [imageView2 setImageUrl:[NSURL URLWithString:@"https://sta-op-test.douyucdn.cn/wsd-ecl-img/2020/09/08/760ff932f16397abe89d099772e64792.jpg"]];
    
    
    UIImageView *imageView3=[[UIImageView alloc]initWithFrame:CGRectMake(60, 320, 200, 120)];
    imageView3.backgroundColor=[UIColor greenColor];
    [imageView2 setImageUrl:[NSURL URLWithString:@"https://live.dz11.com/upload/avatar_v3/202102/c46721bfd48246d2991b72900f341add_middle.jpg"]];
    [imageView2 setImageUrl:[NSURL URLWithString:@"https://live.dz11.com/upload/avatar/default/11_middle.jpg"]];
    [self.view addSubview:imageView];
    [self.view addSubview:imageView2];
    [self.view addSubview:imageView3];
}

//- (void)buyTicket {
//
//    _restCount = 20;
//    dispatch_queue_t queue = dispatch_queue_create("trainStation", DISPATCH_QUEUE_CONCURRENT);
//
//    dispatch_async(queue, ^{
//        [self saleTickets:queue];
//    });
//
//    dispatch_queue_t queue2 = dispatch_queue_create("trainStation2", DISPATCH_QUEUE_CONCURRENT);
//
//    dispatch_sync(queue2, ^{
//        [self saleTickets:queue2];
//
//    });
//
//    dispatch_queue_t queue3 = dispatch_queue_create("trainStation3", DISPATCH_QUEUE_CONCURRENT);
//
//    dispatch_sync(queue3, ^{
//        [self saleTickets:queue3];
//
//    });
//
//}

- (void)saleTickets:(dispatch_queue_t)queue{
    while (_restCount > 0) {
        @synchronized (self) {
            if (_restCount >0) {
                // 如果还有票，继续售卖
                NSInteger count = arc4random() % 3 + 1; // 在窗口购买任意n+1张票
                if (_restCount == 1)
                {
                    count = 1;
                }
                _restCount -= count; // 剩余票数
                const char *queueLabel = dispatch_queue_get_label(queue);
                NSString *label = [NSString stringWithUTF8String:queueLabel];
                NSLog(@"%@售出%ld，余票：%d张",label, (long)count, _restCount);
            }
           
        }
            
    }
}

- (void)useGCDTest {
//    [self syncSerial];
    
//    [self asyncSerial];
    
//    [self syncConcurrent];
    
    [self asyncConcurrent];
}

- (void)syncSerial {
    
    NSLog(@"**************串行同步***************");
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"串行同步1：%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"串行同步2：%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"串行同步3：%@", [NSThread currentThread]);
        }
    });
}

- (void)asyncSerial {
    NSLog(@"**************串行异步***************");
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"串行异步1：%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"串行异步2：%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"串行异步3：%@", [NSThread currentThread]);
        }
    });
}

- (void)syncConcurrent {
    NSLog(@"**************并行同步***************");
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"并行同步1：%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"并行同步2：%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"并行同步3：%@", [NSThread currentThread]);
        }
    });
    
}

- (void)asyncConcurrent {
    NSLog(@"**************并行异步***************");
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"并行异步1：%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"并行异步2：%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"并行异步3：%@", [NSThread currentThread]);
        }
    });
    
}

- (void)threadTest {
    // 方法一：需要start
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething1:) object:@"NSThread1"];
    [thread1 start];
    
    /** 方法二，创建好之后自动启动 */
//    [NSThread detachNewThreadSelector:@selector(doSomething2:) toTarget:self withObject:@"NSThread2"];

    /** 方法三，隐式创建，直接启动 */
//    [self performSelectorInBackground:@selector(doSomething3:) withObject:@"NSThread3"];
}

- (void)doSomething1:(NSObject *)object {
    // 传递过来的参数
    NSLog(@"%@",object);
    NSLog(@"doSomething1：%@",[NSThread currentThread]);
}

- (void)doSomething2:(NSObject *)object {
    NSLog(@"%@",object);
    NSLog(@"doSomething2：%@",[NSThread currentThread]);
}

- (void)doSomething3:(NSObject *)object {
    NSLog(@"%@",object);
    NSLog(@"doSomething3：%@",[NSThread currentThread]);
}
@end
