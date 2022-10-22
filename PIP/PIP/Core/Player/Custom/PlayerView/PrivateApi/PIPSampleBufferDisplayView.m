//
//  PIPSampleBufferDisplayView.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/17.
//

#import "PIPSampleBufferDisplayView.h"

#import <AVFoundation/AVFoundation.h>

@interface PIPSampleBufferDisplayView ()

@end

@implementation PIPSampleBufferDisplayView

+ (Class)layerClass {
    return [AVSampleBufferDisplayLayer class];
}

- (AVSampleBufferDisplayLayer *)sampleBufferDisplayLayer {
    return (AVSampleBufferDisplayLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0;
    }
    return self;
}

- (void)updateWithVideoSize:(CGSize)videoSize {
    CMTimebaseRef timebase;
    CMTimebaseCreateWithSourceClock(nil, CMClockGetHostTimeClock(), &timebase);
    CMTimebaseSetTime(timebase, kCMTimeZero);
    CMTimebaseSetRate(timebase, 1);
    self.sampleBufferDisplayLayer.controlTimebase = timebase;
    if (timebase) {
        CFRelease(timebase);
    }
    
    CMSampleBufferRef sampleBuffer = [self makeSampleBufferWithVideoSize:videoSize];
    if (sampleBuffer) {
        [self.sampleBufferDisplayLayer enqueueSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
    }
}

- (CMSampleBufferRef)makeSampleBufferWithVideoSize:(CGSize)videoSize
{
    size_t width = (size_t)videoSize.width;
    size_t height = (size_t)videoSize.height;
    
    const int pixel = 0xFF000000;// {0x00, 0x00, 0x00, 0xFF};//BGRA
    
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferCreate(NULL, width, height, kCVPixelFormatType_32BGRA,
                        (__bridge CFDictionaryRef)@{
        (id)kCVPixelBufferIOSurfacePropertiesKey: @{}
    }, &pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int *bytes = CVPixelBufferGetBaseAddress(pixelBuffer);
    for (NSUInteger i = 0, length = height * CVPixelBufferGetBytesPerRow(pixelBuffer) / 4 ; i < length; ++i) {
        bytes[i] = pixel;
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CMSampleBufferRef sampleBuffer = [self makeSampleBufferWithPixelBuffer:pixelBuffer];
    CVPixelBufferRelease(pixelBuffer);
    return sampleBuffer;
}

- (CMSampleBufferRef)makeSampleBufferWithPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    CMSampleBufferRef sampleBuffer = NULL;
    OSStatus err = noErr;
    CMVideoFormatDescriptionRef formatDesc = NULL;
    err = CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &formatDesc);

    if (err != noErr) {
        return nil;
    }

    CMSampleTimingInfo sampleTimingInfo = {
        .duration = CMTimeMakeWithSeconds(1, 600),
        .presentationTimeStamp = CMTimebaseGetTime(self.sampleBufferDisplayLayer.timebase),
        .decodeTimeStamp = kCMTimeInvalid
    };

    err = CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, formatDesc, &sampleTimingInfo, &sampleBuffer);

    if (err != noErr) {
        return nil;
    }

    CFRelease(formatDesc);

    return sampleBuffer;
}

@end
