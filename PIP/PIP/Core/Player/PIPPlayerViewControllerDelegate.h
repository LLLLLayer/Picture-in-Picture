//
//  PIPPlayerViewControllerDelegate.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PIPPlayerViewControllerDelegate <NSObject>

- (void)restorePlayerViewController:(UIViewController *)viewController
              withCompletionHandler:(void (^)(BOOL restored))completionHandler;

@end

NS_ASSUME_NONNULL_END
