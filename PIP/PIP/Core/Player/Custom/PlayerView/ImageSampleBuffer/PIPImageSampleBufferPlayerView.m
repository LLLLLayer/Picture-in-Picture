//
//  PIPImageSampleBufferPlayerView.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/16.
//

#import "PIPResourcesManager.h"
#import "PIPPlayerViewDelegate.h"
#import "PIPImageSampleBufferPlayerView.h"

#import <AVFoundation/AVFoundation.h>

@interface PIPImageSampleBufferPlayerView () <AVPictureInPictureSampleBufferPlaybackDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *sampleBufferDisplayLayer;

@property (nonatomic, strong) NSArray<UIImage *> *images;
@property (nonatomic, strong) NSTimer *loopTimer;
@property (nonatomic, strong) id timeObserver;

@end

@implementation PIPImageSampleBufferPlayerView

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
        _player = [AVPlayer playerWithURL:url];
        
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

- (NSArray<UIImage *> *)images {
    if (!_images) {
        _images = [PIPResourcesManager images];
    }
    return _images;
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
        [self.player play];
        __block NSInteger index = 0;
        __weak typeof(self) weakSelf = self;
        self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            CVPixelBufferRef pxbuffer = [PIPImageSampleBufferPlayerView CVPixelBufferRefFromUiImage:weakSelf.images[index]];
            [weakSelf __displayPixelBuffer:pxbuffer];
            
            index++;
            
            if (index >= weakSelf.images.count) {
                index = 0;
            }
        }];
        [self.loopTimer fire];
    }
}

- (void)pause {
    if (self.isPlaying) {
        [self.player pause];
        [self.loopTimer invalidate];
        self.loopTimer = nil;
    }
}

- (void)skipByInterval:(NSTimeInterval)skipInterval completionHandler:(void (^)(NSTimeInterval currentSeconds))completionHandler {
    CMTime currentTime = CMTimeMake(self.player.currentTime.value + self.player.currentTime.timescale * skipInterval, self.player.currentTime.timescale);
    if (CMTimeCompare(currentTime, kCMTimeZero) < 0) {
        currentTime = kCMTimeZero;
    }
    if (CMTimeCompare(currentTime, [self duration]) > 0) {
        currentTime = [self duration];
    }
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            CMTimebaseSetTime(self.sampleBufferDisplayLayer.controlTimebase, currentTime);
            completionHandler(currentTime.value / currentTime.timescale);
        }
    }];
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


- (AVPictureInPictureController *)createPiPController {
    AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.sampleBufferDisplayLayer playbackDelegate:self];
    AVPictureInPictureController *pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
    pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
    return pipController;
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
                    skipByInterval:(CMTime)skipInterval completionHandler:(nonnull void (^)(void))completionHandler {
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

#pragma mark - Convert UIImage to CVPixelBuffer

static OSType inputPixelFormat(){
    return kCVPixelFormatType_32BGRA;
}

static uint32_t bitmapInfoWithPixelFormatType(OSType inputPixelFormat, bool hasAlpha){
    
    if (inputPixelFormat == kCVPixelFormatType_32BGRA) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        return bitmapInfo;
    }else if (inputPixelFormat == kCVPixelFormatType_32ARGB) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big;
        return bitmapInfo;
    }else{
        NSLog(@"不支持此格式");
        return 0;
    }
}

// alpha的判断
BOOL CGImageRefContainsAlpha(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

// 此方法能还原真实的图片
+ (CVPixelBufferRef)CVPixelBufferRefFromUiImage:(UIImage *)img {
    CGSize size = img.size;
    CGImageRef image = [img CGImage];
    
    BOOL hasAlpha = CGImageRefContainsAlpha(image);
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             empty, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, inputPixelFormat(), (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    uint32_t bitmapInfo = bitmapInfoWithPixelFormatType(inputPixelFormat(), (bool)hasAlpha);
    
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, bitmapInfo);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    return pxbuffer;
}

@end
