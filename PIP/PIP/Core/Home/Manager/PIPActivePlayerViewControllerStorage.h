//
//  PIPActivePlayerViewControllerStorage.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PIPActivePlayerViewControllerStorage : NSObject

+ (instancetype)sharedInstance;

- (void)storePlayerViewController:(UIViewController *)viewController;

- (void)removePlayerViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
