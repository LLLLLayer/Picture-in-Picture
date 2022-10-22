//
//  PIPStandardPlayerViewController.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/13.
//

#import <UIKit/UIKit.h>
#import "PIPPlayerViewControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface PIPStandardPlayerViewController : UIViewController

@property (nonatomic, weak) id<PIPPlayerViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
