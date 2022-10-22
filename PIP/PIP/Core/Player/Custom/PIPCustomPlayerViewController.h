//
//  PIPCustomPlayerViewController.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PIPPlayerViewControllerDelegate;

typedef NS_ENUM(NSInteger, PIPCustomPlayerViewType) {
    PIPCustomPlayerViewTypeNormal,
    PIPCustomPlayerViewTypeSampleBuffer,
    PIPCustomPlayerViewTypeImageSampleBuffer,
    PIPCustomPlayerViewTypePrivateApi,
};

@interface PIPCustomPlayerViewController : UIViewController

@property (nonatomic, assign) PIPCustomPlayerViewType type;

@property (nonatomic, weak) id<PIPPlayerViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
