//
//  PIPSampleBufferPlayerView.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/16.
//

#import "PIPPlayerViewDelegate.h"
#import "PIPSampleBufferPlayerView.h"
#import "PIPWeakProxy.h"

#import <AVFoundation/AVFoundation.h>

@interface PIPSampleBufferPlayerView () <AVPictureInPictureSampleBufferPlaybackDelegate>

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) AVSampleBufferDisplayLayer *sampleBufferDisplayLayer;

@property (nonatomic, strong) id timeObserver;

@end

@implementation PIPSampleBufferPlayerView

@synthesize isPlaying;
@synthesize delegate = _delegate;

+ (Class)layerClass {
    return [AVSampleBufferDisplayLayer class];
}

- (AVSampleBufferDisplayLayer *)sampleBufferDisplayLayer {
    return (AVSampleBufferDisplayLayer *)self.layer;
}

- (instancetype)initWithVideoUrl:(NSURL *)url {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        
        _player = [AVPlayer playerWithURL:url];
        _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:@{
            (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        }];
        [_player.currentItem addOutput:_videoOutput];
        
        PIPWeakProxy *proxy = [PIPWeakProxy proxyForObject:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:proxy selector:@selector(__displayLinkDidRefreshed:)];
        
        [self __setupTimebase];
        
        __weak typeof(self) weakSelf = self;
        _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC)
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

- (void)__displayLinkDidRefreshed:(CADisplayLink *)link {
    CMTime itemTime = [self.videoOutput itemTimeForHostTime:CACurrentMediaTime()];
    if ([self.videoOutput hasNewPixelBufferForItemTime:itemTime]) {
        CMTime outItemTimeForDisplay = kCMTimeZero;
        CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:itemTime itemTimeForDisplay:&outItemTimeForDisplay];
        [self __displayPixelBuffer:pixelBuffer];
    }
}

- (void)__displayPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer){
        return;
    }
    
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};

    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    
    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    CFRelease(pixelBuffer);
    CFRelease(videoInfo);
    
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    
    if (self.sampleBufferDisplayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [self.sampleBufferDisplayLayer flush];
    }
    
    [self.sampleBufferDisplayLayer enqueueSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
}

- (void)__setupTimebase {
    CMTimebaseRef timebase;
    CMTimebaseCreateWithSourceClock(nil, CMClockGetHostTimeClock(), &timebase);
    CMTimebaseSetTime(timebase, kCMTimeZero);
    CMTimebaseSetRate(timebase, 1);
    self.sampleBufferDisplayLayer.controlTimebase = timebase;
    if (timebase) {
        CFRelease(timebase);
    }
}

- (BOOL)isPlaying {
    return (self.player.rate != 0) && (self.player.error == nil);
}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsPlaying {
    return [NSSet setWithObjects:@"player.rate", @"player,error", nil];
}

- (CMTime)duration {
    return self.player.currentItem.asset.duration;
}

- (void)play {
    if (!self.isPlaying) {
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self.player play];
    }
}

- (void)pause {
    if (self.isPlaying) {
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self.player pause];
    }
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
            CMTimebaseSetTime(self.sampleBufferDisplayLayer.controlTimebase, currentTime);
            completionHandler(currentTime.value / currentTime.timescale);
        }
    }];
}

#pragma mark - AVPictureInPictureSampleBufferPlaybackDelegate

///  PiP 窗口大小改变
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
         didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    
}

/// 点击 PiP 窗口中的播放/暂停
- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController
                        setPlaying:(BOOL)playing {
    if (playing) {
        [self play];
    } else {
        [self pause];
    }
}

/// 点击 PiP 窗口中的快进后图
- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController
                    skipByInterval:(CMTime)skipInterval completionHandler:(nonnull void (^)(void))completionHandler {
    [self skipByInterval:(skipInterval.value / skipInterval.timescale)
       completionHandler:^(NSTimeInterval currentSeconds) {
        completionHandler();
    }];
}

/// 前视频是否处于暂停状态
/// 当点击播放/暂停按钮时，PiP 会调用该方法，决定 setPlaying: 的值，同时该方法返回值也决定了PiP窗口展示击播放/暂停 icon
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
    return !self.isPlaying;
}

/// 视频的可播放时间范围
- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(nonnull AVPictureInPictureController *)pictureInPictureController {
    return CMTimeRangeMake(kCMTimeZero, [self duration]);
}

- (AVPictureInPictureController *)createPiPController {
    AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.sampleBufferDisplayLayer playbackDelegate:self];
    AVPictureInPictureController *pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
    pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
    return pipController;
}

@end
