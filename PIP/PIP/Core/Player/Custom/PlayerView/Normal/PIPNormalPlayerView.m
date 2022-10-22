//
//  PIPNormalPlayerView.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import "PIPPlayerViewDelegate.h"
#import "PIPNormalPlayerView.h"

#import <AVFoundation/AVFoundation.h>

@interface PIPNormalPlayerView ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) id timeObserver;

@end

@implementation PIPNormalPlayerView

@synthesize isPlaying;
@synthesize delegate = _delegate;

- (instancetype)initWithVideoUrl:(NSURL *)url {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        
        _player = [AVPlayer playerWithURL:url];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.layer addSublayer:_playerLayer];
        
        __weak typeof(self) weakSelf = self;
        self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time) {
            __strong typeof(self) strongSelf = weakSelf;
            CGFloat progress = CMTimeGetSeconds(strongSelf.player.currentItem.currentTime) / CMTimeGetSeconds(strongSelf.player.currentItem.duration);
            [strongSelf.delegate playerView:strongSelf updateProgress:progress];
        }];
    }
    return self;
}

- (void)dealloc {
    [_player removeTimeObserver:_timeObserver];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (BOOL)isPlaying {
    return (self.player.rate != 0) && (self.player.error == nil);
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsPlaying
{
    return [NSSet setWithObjects:@"player.rate", @"player,error", nil];
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
    CMTime currentTime = CMTimeMake(self.player.currentTime.value + self.player.currentTime.timescale * skipInterval, self.player.currentTime.timescale);
    if (CMTimeCompare(currentTime, kCMTimeZero) < 0) {
        currentTime = kCMTimeZero;
    } else if (CMTimeCompare(currentTime, [self duration]) > 0) {
        currentTime = [self duration];
    }
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            completionHandler(currentTime.value / currentTime.timescale);
        }
    }];
}

- (AVPictureInPictureController *)createPiPController {
    AVPictureInPictureController *pipController = [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
    pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
    return pipController;
}

@end
