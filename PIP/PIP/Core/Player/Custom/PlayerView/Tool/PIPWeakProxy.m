//
//  PIPWeakProxy.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/20.
//

#import "PIPWeakProxy.h"

@interface PIPWeakProxy ()

@property (nonatomic, weak) id target;

@end

@implementation PIPWeakProxy

+ (instancetype)proxyForObject:(id)obbject {
    PIPWeakProxy *weakProxy = [PIPWeakProxy alloc];
    weakProxy.target = obbject;
    return weakProxy;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL sel = [invocation selector];
    if ([self.target respondsToSelector:sel]) {
        [invocation invokeWithTarget:self.target];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel] ?: [NSObject methodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.target respondsToSelector:aSelector];
}


@end
