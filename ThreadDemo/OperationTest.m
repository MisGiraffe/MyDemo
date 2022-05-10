//
//  OperationTest.m
//  ThreadDemo
//
//  Created by fangtingting on 2021/5/11.
//

#import "OperationTest.h"

@implementation OperationTest

- (void)main {
    for (int i = 0; i < 3; i++) {
            NSLog(@"NSOperation的子类OperationTest======%@",[NSThread currentThread]);
        }
}

@end
