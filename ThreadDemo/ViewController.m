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
        //20???
        for (int i=0;i<20;i++) {
            if (self.totalCount == 0) {
                NSLog(@"%@===%@??????????????????",[NSThread currentThread], @"trainQueue");
                break;
            }
            //??????????????????????????????????????????
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
        //20???
        for (int i=0;i<10;i++) {
            if (self.totalCount == 0) {
                NSLog(@"%@===%@??????????????????",[NSThread currentThread], @"trainQueue_2");
                break;
            }
            //??????????????????????????????????????????
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
        NSLog(@"%@===%@???????????????%d??????",[NSThread currentThread], label, self.totalCount);
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
            NSLog(@"%@===%@??????%ld????????????%d???",[NSThread currentThread], label, (long)count, self.totalCount);
        }
        else {
            NSLog(@"%@===%@?????????%d???",[NSThread currentThread], label, self.totalCount);
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
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1]; // ??????????????????condition=1
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [lock lockWhenCondition:1]; // ???condition=1??? ??????????????? ?????????????????????????????????lockWhenCondition???condition?????????????????????????????????
        
        NSLog(@"%@===A===start",[NSThread currentThread]);
        sleep(2);
        NSLog(@"%@===A===end",[NSThread currentThread]);
        
        // unlock????????????????????? ?????????????????????
        [lock unlockWithCondition:2]; // ?????????????????????condition=2???signal???
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
       
       // async???????????????????????????????????????
//       dispatch_barrier_async(queue, ^{
//           NSLog(@"%@===Barrier",[NSThread currentThread]);
//       });
       // sync????????????????????????????????????
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
    // group??????????????????????????????????????? ??????global??????????????????
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
   //        dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC))); // ?????????????????????????????????
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
    // ?????? ??????sem_t *sem_open(const char *name,int oflag,mode_t mode,unsigned int value);
    // name ?????????????????????
    // oflag ?????????????????????????????????????????????
    // mode ?????????
    // value ???????????????
    sem_t *sem = sem_open("semname", O_CREAT, 0644, 1);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        sem_wait(sem); // ?????????????????????value ??????=0??????????????????value-1??????????????????
        NSLog(@"%@===write===start",[NSThread currentThread]);
        sleep(3);
        NSLog(@"%@===write===end",[NSThread currentThread]);
        sem_post(sem); // ????????????????????????value+1
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
    // 1.???????????????
    static pthread_cond_t cond_lock = PTHREAD_COND_INITIALIZER;
    static pthread_mutex_t mutex_lock = PTHREAD_MUTEX_INITIALIZER; // ????????????mutex???????????????
    
    // 2.????????????
    static pthread_cond_t cond_lock1;
    pthread_cond_init(&cond_lock1, NULL);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        pthread_mutex_lock(&mutex_lock);
        while (self.condition_value <= 0) { // ????????????????????????????????????
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
        self.condition_value = 1; // ????????????????????? ????????????read????????????????????????wait
        NSLog(@"%@===write===end",[NSThread currentThread]);
        
        pthread_cond_signal(&cond_lock); // ?????????????????????????????? ?????????????????????
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
    // ?????????????????????
    // 1.???????????????
    static pthread_rwlock_t lock = PTHREAD_RWLOCK_INITIALIZER;
    
    // 2.????????????
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
    // PTHREAD_MUTEX_NORMAL??????????????? PTHREAD_MUTEX_RECURSIVE?????????
    pthread_mutexattr_settype(&att, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_lock, &att);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [self recursiveTest:3]; // ????????????
    }];
}

// ????????????
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
    //????????????????????????
    //1??????????????????
    static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    
    //2???????????????
    pthread_mutex_t lock1;
    // ????????????????????????pthread_mutexattr NULL??????????????????
    pthread_mutex_init(&lock1, NULL);
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        pthread_mutex_lock(&lock);//??????
        NSLog(@"%@===write===start",[NSThread currentThread]);
        sleep(3);
        NSLog(@"%@===write===end",[NSThread currentThread]);
        pthread_mutex_unlock(&lock); // ??????
    }];
    
    [queue addOperationWithBlock:^{
        pthread_mutex_lock(&lock);//??????
        NSLog(@"%@===read===start",[NSThread currentThread]);
        sleep(2);
        NSLog(@"%@===read===end",[NSThread currentThread]);
        pthread_mutex_unlock(&lock); // ??????
    }];
}

- (void)testBarrier {
    // ????????????
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    
    // ????????????
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"?????????????????????1   %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"?????????????????????2   %@",[NSThread currentThread]);
        }
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"------------barrier------------%@", [NSThread currentThread]);
        NSLog(@"******* ???????????????????????????34?????????12?????? *********");
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"?????????????????????3   %@",[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"?????????????????????4   %@",[NSThread currentThread]);
        }
    });
}

- (void)testAddDependency {

    // ????????????
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // ??????1
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"operation1======%@", [NSThread  currentThread]);
        }
    }];

    // ??????2
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"****operation2?????????operation1????????????operation1???????????????operation2????????????****");
        for (int i = 0; i < 3; i++) {
            NSLog(@"operation2======%@", [NSThread  currentThread]);
        }
    }];

    // ?????????2???????????????1
    [operation2 addDependency:operation1];
    // ?????????????????????
    [queue addOperation:operation1];
    [queue addOperation:operation2];
}

- (void)testMaxConcurrentOperationCount {
    // ???????????????????????????
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];

    // ??????????????????1?????????
//    queue.maxConcurrentOperationCount = 1;

    // ??????????????????2?????????
    queue.maxConcurrentOperationCount = 2;


    // ?????????????????????
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"addOperationWithBlock????????????????????????1======%@", [NSThread currentThread]);
        }
    }];
    // ?????????????????????
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"addOperationWithBlock????????????????????????2======%@", [NSThread currentThread]);
        }
    }];

    // ?????????????????????
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            NSLog(@"addOperationWithBlock????????????????????????3======%@", [NSThread currentThread]);
        }
    }];
}

- (void)testOperationQueueWithBlock {
    //???????????????????????????
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //?????????????????????
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"addOperationWithBlock????????????????????????======%@", [NSThread currentThread]);
        }
    }];
}

- (void)testOperationQueue {
    //???????????????????????????
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //???????????????NSInvocationOperation
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queueOperationAddOperation) object:nil];
    
    // ???????????????NSBlockOperation
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
        NSLog(@"NSBlockOperation?????????---%@",[NSThread currentThread]);
    }];
    
    [bp addExecutionBlock:^{
        NSLog(@"addExecutionBlock??????????????????1========%@", [NSThread currentThread]);
    }];
    
    [bp addExecutionBlock:^{
        NSLog(@"addExecutionBlock??????????????????2========%@", [NSThread currentThread]);
    }];
    
    [bp addExecutionBlock:^{
        NSLog(@"addExecutionBlock??????????????????3========%@", [NSThread currentThread]);
    }];
    
    [bp start];
}

- (void)useInvocationOperation {
    // 1.?????? NSInvocationOperation ??????
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    // 2.?????? start ????????????????????????
    [op start];
}

- (void)task1{
    for (int i=0;i<3;i++) {
        NSLog(@"NSInvocationOperation---%@",[NSThread currentThread]);
    }
}

- (void)ascynImage {
    //??????????????????
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
                // ??????????????????????????????
                NSInteger count = arc4random() % 3 + 1; // ?????????????????????n+1??????
                if (_restCount == 1)
                {
                    count = 1;
                }
                _restCount -= count; // ????????????
                const char *queueLabel = dispatch_queue_get_label(queue);
                NSString *label = [NSString stringWithUTF8String:queueLabel];
                NSLog(@"%@??????%ld????????????%d???",label, (long)count, _restCount);
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
    
    NSLog(@"**************????????????***************");
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????1???%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????2???%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????3???%@", [NSThread currentThread]);
        }
    });
}

- (void)asyncSerial {
    NSLog(@"**************????????????***************");
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????1???%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????2???%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????3???%@", [NSThread currentThread]);
        }
    });
}

- (void)syncConcurrent {
    NSLog(@"**************????????????***************");
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????1???%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????2???%@", [NSThread currentThread]);
        }
    });
    
    dispatch_sync(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????3???%@", [NSThread currentThread]);
        }
    });
    
}

- (void)asyncConcurrent {
    NSLog(@"**************????????????***************");
    
    dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????1???%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????2???%@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i=0;i<3;i++) {
            NSLog(@"????????????3???%@", [NSThread currentThread]);
        }
    });
    
}

- (void)threadTest {
    // ??????????????????start
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(doSomething1:) object:@"NSThread1"];
    [thread1 start];
    
    /** ??????????????????????????????????????? */
//    [NSThread detachNewThreadSelector:@selector(doSomething2:) toTarget:self withObject:@"NSThread2"];

    /** ??????????????????????????????????????? */
//    [self performSelectorInBackground:@selector(doSomething3:) withObject:@"NSThread3"];
}

- (void)doSomething1:(NSObject *)object {
    // ?????????????????????
    NSLog(@"%@",object);
    NSLog(@"doSomething1???%@",[NSThread currentThread]);
}

- (void)doSomething2:(NSObject *)object {
    NSLog(@"%@",object);
    NSLog(@"doSomething2???%@",[NSThread currentThread]);
}

- (void)doSomething3:(NSObject *)object {
    NSLog(@"%@",object);
    NSLog(@"doSomething3???%@",[NSThread currentThread]);
}
@end
