//
//  PIPResourcesManager.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/13.
//

#import "PIPResourcesManager.h"

@implementation PIPResourcesManager

+ (NSURL *)videoUrl {
    return [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"];
}

+ (NSURL *)misicUrl {
    return [[NSBundle mainBundle] URLForResource:@"music" withExtension:@"mp3"];
}

+ (NSArray<UIImage *> *)images {
    NSMutableArray<UIImage *> *images = @[].mutableCopy;
    [@[@"image0", @"image1", @"image2"] enumerateObjectsUsingBlock:^(NSString *imgName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:imgName ofType:@"jpg"];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        [images addObject:image];
    }];
    return [images copy];
}

@end
