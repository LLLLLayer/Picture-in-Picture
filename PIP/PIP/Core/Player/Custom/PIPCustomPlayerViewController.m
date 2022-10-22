//
//  PIPCustomPlayerViewController.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import "PIPPlayerViewProtocol.h"
#import "PIPPlayerViewDelegate.h"
#import "PIPPlayerViewControllerDelegate.h"

#import "PIPResourcesManager.h"
#import "PIPActivePlayerViewControllerStorage.h"

#import "PIPCustomPlayerControlsView.h"
#import "PIPCustomPlayerViewController.h"

#import "PIPNormalPlayerView.h"
#import "PIPSampleBufferPlayerView.h"
#import "PIPPrivateApiPlayerView.h"
#import "PIPImageSampleBufferPlayerView.h"

#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <objc/message.h>

@interface PIPCustomPlayerViewController ()
<
PIPPlayerViewDelegate,
PIPCustomPlayerControlsViewDelegate,
AVPictureInPictureControllerDelegate
>

/// 画中画控制器
@property (nonatomic, strong) AVPictureInPictureController *pipController;

/// 播放器视图
@property (nonatomic, strong) UIView<PIPPlayerViewProtocol> *playerView;

/// 播放控件视图
@property (nonatomic, strong) PIPCustomPlayerControlsView *controlsView;

/// 播放控件视图隐藏状态
@property (nonatomic, assign) BOOL hiddenControlsView;

@end

@implementation PIPCustomPlayerViewController

@synthesize isPlaying;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupUI];
    
    // 设置画中画控制器
    if (AVPictureInPictureController.isPictureInPictureSupported) {
        self.pipController = [self.playerView createPiPController];
        self.pipController.delegate = self;
        [self.controlsView updatePipEnable:YES];
    } else {
        [self.controlsView updatePipEnable:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self __play];
}

#pragma mark - UI

- (void)__setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__handleViewTapped:)]];
    
    [self.view addSubview:self.playerView];
    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.playerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.playerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.playerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.playerView.heightAnchor constraintEqualToConstant:300.0],
    ]];
    
    [self.view addSubview:self.controlsView];
    self.controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.controlsView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.controlsView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:- 16.0],
        [self.controlsView.topAnchor constraintEqualToAnchor:self.playerView.bottomAnchor constant:8.0],
        [self.controlsView.heightAnchor constraintEqualToConstant:30.0],
    ]];
}

- (void)__hiddenControlsView:(BOOL)hiddenControlsView {
    self.hiddenControlsView = !self.hiddenControlsView;
    [UIView animateWithDuration:0.3 animations:^{
        self.controlsView.alpha = self.hiddenControlsView ? 0 : 1;
    }];
}

#pragma mark - Action

- (void)__handleViewTapped:(UITapGestureRecognizer *)tapGesture {
    [self __hiddenControlsView:!self.hiddenControlsView];
}

#pragma mark - Getter

- (BOOL)isPlaying {
    return self.playerView.isPlaying;
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsPlaying {
    return [NSSet setWithObjects:@"playerView.isPlaying", nil];
}

- (UIView<PIPPlayerViewProtocol> *)playerView {
    if (!_playerView) {
        switch (self.type) {
            case PIPCustomPlayerViewTypeNormal:
                _playerView = [[PIPNormalPlayerView alloc] initWithVideoUrl:[PIPResourcesManager videoUrl]];
                break;
            case PIPCustomPlayerViewTypeSampleBuffer:
                _playerView = [[PIPSampleBufferPlayerView alloc] initWithVideoUrl:[PIPResourcesManager videoUrl]];
                break;
            case PIPCustomPlayerViewTypeImageSampleBuffer:
                _playerView =  [[PIPImageSampleBufferPlayerView alloc] initWithVideoUrl:[PIPResourcesManager videoUrl]];
                break;
            case PIPCustomPlayerViewTypePrivateApi:
                _playerView = [[PIPPrivateApiPlayerView alloc] initWithVideoUrl:[PIPResourcesManager videoUrl]];
                break;
        }
        _playerView.delegate = self;
    }
    return _playerView;
}

- (PIPCustomPlayerControlsView *)controlsView {
    if (!_controlsView) {
        _controlsView = [[PIPCustomPlayerControlsView alloc] initWithFrame:CGRectZero];
        _controlsView.delegate = self;
    }
    return _controlsView;
}

#pragma mark - Controls

- (void)__play {
    [self.playerView play];
    [self.pipController invalidatePlaybackState];
}

- (void)__pause {
    [self.playerView pause];
    [self.pipController invalidatePlaybackState];
}

- (void)__skipByInterval:(NSTimeInterval)skipInterval completionHandler:(void (^)(NSTimeInterval currentSeconds))completionHandler {
    [self.playerView skipByInterval:skipInterval completionHandler:completionHandler];
}

#pragma mark - PIPPlayerViewDelegate

- (void)playerView:(nonnull UIView<PIPPlayerViewProtocol> *)playerView updateProgress:(CGFloat)progress {
    [self.controlsView updateProgress:progress];
    if (progress == 1.0) {
        [self __pause];
        if (self.pipController.pictureInPictureActive) {
            [self __stopPictureInPicture];
        }
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
    }
}

- (void)__stopPictureInPicture {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        SEL selStopPictureInPicture = NSSelectorFromString([NSString stringWithFormat:@"stopPictureInPictureEvenWhenInBackground"]);
        if ([self.pipController respondsToSelector:selStopPictureInPicture]) {
            ((void(*)(id, SEL))objc_msgSend)(self.pipController, selStopPictureInPicture);
            return;
        }
    }
    [self.pipController stopPictureInPicture];
}

- (void)restorePlayerView:(nonnull UIView<PIPPlayerViewProtocol> *)playerView {
    [self.view addSubview:self.playerView];
    [self.view sendSubviewToBack:self.playerView];
    for (NSLayoutConstraint *constraint in self.playerView.constraints) {
        [self.playerView removeConstraint:constraint];
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.playerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.playerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.playerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.playerView.heightAnchor constraintEqualToConstant:300.0],
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.controlsView.topAnchor constraintEqualToAnchor:self.playerView.bottomAnchor constant:8.0],
    ]];
}

#pragma mark - AVPictureInPictureControllerDelegate

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self __hiddenControlsView:YES];
    [[PIPActivePlayerViewControllerStorage sharedInstance] storePlayerViewController:self];
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    if ([self.playerView respondsToSelector:@selector(pictureInPictureControllerDidStartPictureInPicture:)]) {
        [self.playerView pictureInPictureControllerDidStartPictureInPicture:pictureInPictureController];
    }
    [self __setupRemoteCommandsAndNowPlayingInfo];
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
failedToStartPictureInPictureWithError:(NSError *)error {
    [[PIPActivePlayerViewControllerStorage sharedInstance] removePlayerViewController:self];
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    if ([self.playerView respondsToSelector:@selector(pictureInPictureControllerDidStopPictureInPicture:)]) {
        [self.playerView pictureInPictureControllerDidStopPictureInPicture:pictureInPictureController];
    }
    [self __disableRemoteCommands];
    [[PIPActivePlayerViewControllerStorage sharedInstance] removePlayerViewController:self];
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    [self.delegate restorePlayerViewController:self withCompletionHandler:completionHandler];
}

#pragma mark - RemoteCommand & NowPlayingInfo

- (void)__setupRemoteCommandsAndNowPlayingInfo {
    [MPRemoteCommandCenter sharedCommandCenter].playCommand.enabled = YES;
    [MPRemoteCommandCenter sharedCommandCenter].pauseCommand.enabled = YES;
    [MPRemoteCommandCenter sharedCommandCenter].skipForwardCommand.enabled = YES;
    [MPRemoteCommandCenter sharedCommandCenter].skipForwardCommand.preferredIntervals = @[@(15)];
    [MPRemoteCommandCenter sharedCommandCenter].skipBackwardCommand.enabled = YES;
    [MPRemoteCommandCenter sharedCommandCenter].skipBackwardCommand.preferredIntervals = @[@(15)];
    
    __weak typeof(self) weakSelf = self;
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf __play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf __pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].skipForwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(self) strongSelf = weakSelf;
        MPSkipIntervalCommand *command = (MPSkipIntervalCommand *)event.command;
        NSTimeInterval skipInterval = command.preferredIntervals[0].floatValue;
        [strongSelf __skipByInterval:skipInterval completionHandler:^(NSTimeInterval currentSeconds) {
            NSMutableDictionary *infoDic = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo.mutableCopy;
            [infoDic setObject:@(currentSeconds) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = infoDic;
        }];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].skipBackwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(self) strongSelf = weakSelf;
        MPSkipIntervalCommand *command = (MPSkipIntervalCommand *)event.command;
        NSTimeInterval skipInterval = command.preferredIntervals[0].floatValue * (-1);
        [strongSelf __skipByInterval:skipInterval completionHandler:^(NSTimeInterval currentSeconds) {
            NSMutableDictionary *infoDic = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo.mutableCopy;
            [infoDic setObject:@(currentSeconds) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = infoDic;
        }];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"MPMediaItemPropertyAlbumTitle" forKey:MPMediaItemPropertyAlbumTitle];
    [infoDic setObject:@"MPMediaItemPropertyTitle" forKey:MPMediaItemPropertyTitle];
    [infoDic setObject:[[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(50, 50) requestHandler:^UIImage * _Nonnull(CGSize size) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"];
        return [UIImage imageWithContentsOfFile:imagePath];
    }] forKey:MPMediaItemPropertyArtwork];
    Float64 duration = CMTimeGetSeconds([self.playerView duration]);
    [infoDic setObject:@(duration) forKey:MPMediaItemPropertyPlaybackDuration];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = infoDic;
}

- (void)__disableRemoteCommands {
    [MPRemoteCommandCenter sharedCommandCenter].playCommand.enabled = NO;
    [MPRemoteCommandCenter sharedCommandCenter].pauseCommand.enabled = NO;
    [MPRemoteCommandCenter sharedCommandCenter].skipForwardCommand.enabled = NO;
    [MPRemoteCommandCenter sharedCommandCenter].skipBackwardCommand.enabled = NO;
}

#pragma mark - PIPCustomPlayerControlsViewDelegate

- (void)controlsView:(PIPCustomPlayerControlsView *)controlsView updatePlayStatus:(BOOL)isPlaying {
    if (!isPlaying) {
        [self __pause];
    } else {
        [self __play];
    }
}

- (void)enterPipWithControlsView:(PIPCustomPlayerControlsView *)controlsView {
    if (!self.pipController.isPictureInPictureActive) {
        [self.pipController startPictureInPicture];
    }
}

@end
