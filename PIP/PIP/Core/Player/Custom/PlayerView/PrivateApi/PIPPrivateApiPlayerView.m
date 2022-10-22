//
//  PIPPrivateApiPlayerView.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import "PIPPrivateApiPlayerView.h"
#import "PIPSampleBufferDisplayView.h"

#import <AVFoundation/AVFoundation.h>

@interface PIPPrivateApiPlayerView () <AVPictureInPictureSampleBufferPlaybackDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) PIPSampleBufferDisplayView *sampleBufferDisplayView;
@property (nonatomic) UIViewController *pipViewController;
@property (nonatomic, strong) id timeObserver;

@end

@implementation PIPPrivateApiPlayerView

@synthesize isPlaying;
@synthesize delegate = _delegate;

- (instancetype)initWithVideoUrl:(NSURL *)url {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        
        _sampleBufferDisplayView = [[PIPSampleBufferDisplayView alloc] init];
        [self addSubview:_sampleBufferDisplayView];
        
        _player = [AVPlayer playerWithURL:url];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [self.layer addSublayer:_playerLayer];
        
        // 使其在后台能够播放
        SEL setPIPModeEnabled = NSSelectorFromString([NSString stringWithFormat:@"setPIPModeEnabled:"]);
        if ([_playerLayer respondsToSelector:setPIPModeEnabled]) {
            IMP imp = [_playerLayer methodForSelector:setPIPModeEnabled];
            void (*setPIPModeEnabledFn)(id, SEL, BOOL) = (void *)imp;
            setPIPModeEnabledFn(_playerLayer, setPIPModeEnabled, YES);
        }
        
        __weak typeof(self) weakSelf = self;
        _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1.0)
                                                              queue:dispatch_get_main_queue()
                                                         usingBlock:^(CMTime time) {
            __strong typeof(self) strongSelf = weakSelf;
            CGFloat progress = CMTimeGetSeconds(strongSelf.player.currentItem.currentTime) / CMTimeGetSeconds(strongSelf.player.currentItem.duration);
            [strongSelf.delegate playerView:strongSelf updateProgress:progress];
        }];
        
        NSArray<AVAssetTrack *> *tracks = [self.player.currentItem.asset tracksWithMediaType:AVMediaTypeVideo];
        [self.sampleBufferDisplayView updateWithVideoSize:tracks.firstObject.naturalSize];
    }
    return self;
}

- (void)dealloc {
    [_player removeTimeObserver:_timeObserver];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _playerLayer.frame = self.bounds;
    _sampleBufferDisplayView.frame = self.bounds;
}

- (AVPictureInPictureController *)createPiPController {
    AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.sampleBufferDisplayView.sampleBufferDisplayLayer playbackDelegate:self];
    AVPictureInPictureController *pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
    pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
    NSString *pipVCName = [NSString stringWithFormat:@"pictureInPictureViewController"];
    self.pipViewController = [pipController valueForKey:pipVCName];
    
    return pipController;
}

- (BOOL)isPlaying {
    return (self.player.rate != 0) && (self.player.error == nil);
}

+(NSSet<NSString *> *)keyPathsForValuesAffectingIsPlaying {
    return [NSSet setWithObjects:@"player.rate", @"player.error", nil];
}

- (CMTime)duration {
    return self.player.currentItem.asset.duration;
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)skipByInterval:(NSTimeInterval)skipInterval completionHandler:(void (^)(NSTimeInterval currentSeconds))completionHandler {
    CMTime currentTime = CMTimeMake(self.player.currentTime.value + self.player.currentTime.timescale * skipInterval, self.player.currentTime.timescale);  // 处理大于总长 或 小于 0的情况
    if (CMTimeCompare(currentTime, kCMTimeZero) < 0) {
        currentTime = kCMTimeZero;
    }
    if (CMTimeCompare(currentTime, [self duration]) > 0) {
        currentTime = [self duration];
    }
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            CMTimebaseSetTime(self.sampleBufferDisplayView.sampleBufferDisplayLayer.controlTimebase, currentTime);
            completionHandler(currentTime.value / currentTime.timescale);
        }
    }];
}

#pragma mark - AVPictureInPictureSampleBufferPlaybackDelegate

- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController
         didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
}

- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController
                        setPlaying:(BOOL)playing {
    if (playing) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController
                    skipByInterval:(CMTime)skipInterval
                 completionHandler:(nonnull void (^)(void))completionHandler {
    [self skipByInterval:(skipInterval.value / skipInterval.timescale) completionHandler:^(NSTimeInterval currentSeconds) {
        completionHandler();
    }];
}

- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
    return !self.isPlaying;
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(nonnull AVPictureInPictureController *)pictureInPictureController {
    return CMTimeRangeMake(kCMTimeZero, [self duration]);
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self removeFromSuperview];
    [self.pipViewController.view addSubview:self];
    [self.pipViewController.view bringSubviewToFront:self];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSLayoutConstraint *constraint in self.constraints) {
        [self removeConstraint:constraint];
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.topAnchor constraintEqualToAnchor:self.pipViewController.view.topAnchor],
        [self.leadingAnchor constraintEqualToAnchor:self.pipViewController.view.leadingAnchor],
        [self.bottomAnchor constraintEqualToAnchor:self.pipViewController.view.bottomAnchor],
        [self.trailingAnchor constraintEqualToAnchor:self.pipViewController.view.trailingAnchor]
    ]];
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self removeFromSuperview];
    [self.delegate restorePlayerView:self];
}

@end
