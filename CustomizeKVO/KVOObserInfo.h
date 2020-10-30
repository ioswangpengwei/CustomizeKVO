//
//  KVOObserInfo.h
//  CustomizeKVO
//
//  Created by MacW on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KVOObserInfo : NSObject
{
    @public
    void *_context;
}

@property (nonatomic, weak) id observer;

@property (nonatomic, copy) NSString *keyPath;

@property (nonatomic, assign) NSKeyValueObservingOptions options;

-(instancetype)initWithObserver:(id)observ keyPath:(NSString *)keyPath option:(NSKeyValueObservingOptions)options contex:(void *)context;

@end

NS_ASSUME_NONNULL_END
