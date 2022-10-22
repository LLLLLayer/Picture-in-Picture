//
//  PIPResourcesManager.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PIPResourcesManager : NSObject

+ (NSURL *)videoUrl;

+ (NSURL *)misicUrl;

+ (NSArray<UIImage *> *)images;

@end

NS_ASSUME_NONNULL_END
