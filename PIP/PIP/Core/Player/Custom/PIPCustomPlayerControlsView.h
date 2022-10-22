//
//  PIPCustomPlayerControlsView.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PIPCustomPlayerControlsView;

@protocol PIPCustomPlayerControlsViewDelegate <NSObject>

@property(nonatomic, assign) BOOL isPlaying;

- (void)controlsView:(PIPCustomPlayerControlsView *)controlsView updatePlayStatus:(BOOL)isPlaying;

- (void)enterPipWithControlsView:(PIPCustomPlayerControlsView *)controlsView;

@end

@interface PIPCustomPlayerControlsView : UIView

@property(nonatomic, weak) id<PIPCustomPlayerControlsViewDelegate> delegate;

- (void)updatePipEnable:(BOOL)enable;

- (void)updateProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
