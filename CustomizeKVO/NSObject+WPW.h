//
//  NSObject+WPW.h
//  CustomizeKVO
//
//  Created by MacW on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^WPWKVOBlock)(id observer,NSString *keyPath,NSDictionary<NSKeyValueChangeKey,id> *change);

@interface NSObject (WPW)

- (void)WPW_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

- (void)WPW_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(WPWKVOBlock)block;

-(void)WPW_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;

@end

NS_ASSUME_NONNULL_END
