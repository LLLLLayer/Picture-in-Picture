//
//  PIPPlayerViewDelegate.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PIPPlayerViewProtocol;

@protocol PIPPlayerViewDelegate <NSObject>

- (void)playerView:(UIView<PIPPlayerViewProtocol> *)playerView updateProgress:(CGFloat)progress;

@optional
- (void)restorePlayerView:(UIView<PIPPlayerViewProtocol> *)playerView;

@end

NS_ASSUME_NONNULL_END
