//
//  PIPActivePlayerViewControllerStorage.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import "PIPActivePlayerViewControllerStorage.h"

@interface PIPActivePlayerViewControllerStorage ()

@property (nonatomic, strong) NSMutableSet<UIViewController *> *viewControllers;

@end

@implementation PIPActivePlayerViewControllerStorage

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _viewControllers = [NSMutableSet set];
    }
    return self;
}

- (void)storePlayerViewController:(UIViewController *)viewController {
    [self.viewControllers addObject:viewController];
}

- (void)removePlayerViewController:(UIViewController *)viewController {
    [self.viewControllers removeObject:viewController];
}

@end
