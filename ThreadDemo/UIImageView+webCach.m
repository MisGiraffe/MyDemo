//
//  UIImageView+webCach.m
//  ThreadDemo
//
//  Created by fangtingting on 2021/5/10.
//

#import "UIImageView+webCach.h"

@implementation UIImageView (webCach)

-(void)setImageUrl:(NSURL *)url {
    
    dispatch_queue_t queue = dispatch_queue_create("inage_cache", NULL);
    
    dispatch_async(queue, ^{
        @synchronized (self) {
            NSLog(@"异步：%@ url : %@",[NSThread currentThread],url);
            NSData *data=[NSData dataWithContentsOfURL:url];
            UIImage *image=[UIImage imageWithData:data];
            
            //让主线程去做
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.image=image;
            });
        }
    });
    
}

@end
