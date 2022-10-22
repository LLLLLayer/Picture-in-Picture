//
//  PIPWeakProxy.h
//  PIP
//
//  Created by yangjie.layer on 2022/10/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PIPWeakProxy : NSObject

+ (instancetype)proxyForObject:(id)obbject;

@end

NS_ASSUME_NONNULL_END
