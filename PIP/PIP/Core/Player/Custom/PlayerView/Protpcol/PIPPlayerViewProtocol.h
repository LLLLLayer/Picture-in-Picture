//
//  PIPPlayerViewProtocol.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PIPPlayerViewDelegate;

@protocol PIPPlayerViewProtocol <NSObject>

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, weak) id<PIPPlayerViewDelegate> delegate;

- (instancetype)initWithVideoUrl:(NSURL *)url;

- (CMTime)duration;

#pragma mark - Action

- (void)play;

- (void)pause;

- (void)skipByInterval:(NSTimeInterval)skipInterval completionHandler:(void (^)(NSTimeInterval currentSeconds))completionHandler;

#pragma mark - PiPController

- (AVPictureInPictureController *)createPiPController;

@optional

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController;

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController;

@end

NS_ASSUME_NONNULL_END
