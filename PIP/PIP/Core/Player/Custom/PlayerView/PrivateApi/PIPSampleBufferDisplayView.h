//
//  PIPSampleBufferDisplayView.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/17.
//

#import <UIKit/UIKit.h>
@class AVSampleBufferDisplayLayer;

NS_ASSUME_NONNULL_BEGIN

@interface PIPSampleBufferDisplayView : UIView

@property (nonatomic) AVSampleBufferDisplayLayer *sampleBufferDisplayLayer;

- (void)updateWithVideoSize:(CGSize)videoSize;

@end

NS_ASSUME_NONNULL_END
