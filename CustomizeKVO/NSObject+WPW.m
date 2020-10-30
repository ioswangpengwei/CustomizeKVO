//
//  NSObject+WPW.m
//  CustomizeKVO
//
//  Created by MacW on 2020/10/30.
//

#import "NSObject+WPW.h"
#import <objc/runtime.h>
#import <objc/message.h>
@interface _KVOObserInfo : NSObject
{
    @public
    void *_context;
}

@property (nonatomic, weak) id observer;

@property (nonatomic, copy) NSString *keyPath;

@property (nonatomic, assign) NSKeyValueObservingOptions options;

@property (nonatomic, copy) WPWKVOBlock  block;


-(instancetype)initWithObserver:(id)observ keyPath:(NSString *)keyPath option:(NSKeyValueObservingOptions)options contex:(void *)context block:(WPWKVOBlock)block;

@end
@implementation _KVOObserInfo
-(instancetype)initWithObserver:(id)observ keyPath:(NSString *)keyPath option:(NSKeyValueObservingOptions)options contex:(void *)context  block:(WPWKVOBlock)block{
    if (self = [super init]) {
        self.observer = observ;
        self.keyPath = keyPath;
        self.options = options;
        self->_context = context;
        self.block = block;
    }
    return  self;
}
@end
static NSString *const  KVOClassPrefix  = @"WPWKVOObserver_";
static NSString *const  KVOAssociateObjectKey = @"KVOAssociateObjectKey";

@implementation NSObject (WPW)

- (void)WPW_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
 
    [self private_addObserver:observer forKeyPath:keyPath options:options block:nil context:context];
    
}

- (void)WPW_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(WPWKVOBlock)block {
    [self private_addObserver:observer forKeyPath:keyPath options:options block:block context:NULL];
}

-(void)private_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options  block:(WPWKVOBlock)block context:(nullable void *)context  {
    [self judgeSetterMethodFromKeyPath:keyPath];
    NSString *newClassName = [NSString stringWithFormat:@"%@%@",KVOClassPrefix,NSStringFromClass([self class])];
    Class newClass = [self createNewClassWithClassName:newClassName];
    object_setClass(self, newClass);
    [self addSetterMethodWithClass:newClass keyPath:keyPath];
    _KVOObserInfo *info = [[_KVOObserInfo alloc] initWithObserver:observer keyPath:keyPath option:options contex:context block:block];
    NSMutableArray *marray = objc_getAssociatedObject(self, (__bridge void *)KVOAssociateObjectKey);
    if (!marray) {
        marray = [NSMutableArray arrayWithCapacity:1];
    }
    
    [marray addObject:info];
    objc_setAssociatedObject(self, (__bridge void *)KVOAssociateObjectKey, marray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)judgeSetterMethodFromKeyPath:(NSString *)keyPath {
    
    SEL setterSel = NSSelectorFromString(setterStringFromKeyPath(keyPath));
    Method method = class_getInstanceMethod([self class], setterSel);
    
    if (!method) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"老铁没有当前%@的setter",keyPath] userInfo:nil];
    }
  
}

-(Class )createNewClassWithClassName:(NSString *)newClassName {
    Class newCLass = NSClassFromString(newClassName);
    if (!newCLass) {
        newCLass =  objc_allocateClassPair([self class], newClassName.UTF8String, 0);
        objc_registerClassPair(newCLass);
        Method classMethod = class_getInstanceMethod([self class], @selector(class));
        const char * methodType =method_getTypeEncoding(classMethod);
        class_addMethod(newCLass,NSSelectorFromString(@"class") ,(IMP) wpw_class, methodType);
        SEL deallocSel = NSSelectorFromString(@"dealloc");
        Method deallocMethod = class_getInstanceMethod([self class], deallocSel);
        const char * deallocMethodType =method_getTypeEncoding(deallocMethod);
        class_addMethod(newCLass,deallocSel ,(IMP) my_dealloc, deallocMethodType);
    }
    return newCLass;
}

-(void)addSetterMethodWithClass:(Class)class keyPath:(NSString *)keyPath {
    SEL setterSel = NSSelectorFromString(setterStringFromKeyPath(keyPath));
    Method method = class_getInstanceMethod(class, setterSel);
    const char * setterType = method_getTypeEncoding(method);
    class_addMethod(class, setterSel, (IMP)wpw_setter, setterType);
    
}
Class wpw_class(id self, SEL _cmd){
    return  class_getSuperclass(object_getClass(self));
}
void my_dealloc(id self,SEL _cmd) {
    object_setClass(self, [self class]);
}

void wpw_setter(id self,SEL _cmd ,NSString *newValue){
    
    NSString *oldValue = [self valueForKey:keyPathFromSetter(_cmd)];
    
    struct objc_super superStruc = {
      .receiver = self,
    .super_class = [self class]
    };
    objc_msgSendSuper(&superStruc,_cmd,newValue);
    NSMutableArray *marray = objc_getAssociatedObject(self, (__bridge void *)KVOAssociateObjectKey);

    for (_KVOObserInfo *info in marray) {
        if ([info.keyPath isEqualToString:keyPathFromSetter(_cmd)]) {
            NSMutableDictionary<NSKeyValueChangeKey,id> *change = [NSMutableDictionary dictionary];
            if (info.options &NSKeyValueObservingOptionNew ) {
                [change setValue:newValue forKey:NSKeyValueChangeNewKey];
            } else {
                [change setValue:oldValue forKey:NSKeyValueChangeOldKey];
                [change setValue:newValue forKey:NSKeyValueChangeNewKey];

            }
            if (info.block) {
                info.block(info.observer, info.keyPath, change);
            } else if ( [info.observer respondsToSelector:@selector(WPW_observeValueForKeyPath:ofObject:change:context:)]) {
                [info.observer WPW_observeValueForKeyPath:info.keyPath ofObject:self change:change context:info->_context];
            }
           
        }
        
    }
    
    
    
}
static NSString * setterStringFromKeyPath(NSString *keyPath) {
    return [NSString stringWithFormat:@"set%@%@:",[[keyPath substringToIndex:1] uppercaseString],[keyPath substringFromIndex:1]];
}

static NSString *keyPathFromSetter(SEL setter) {
    NSString * setterString = NSStringFromSelector(setter);
    NSString *firHandleString = [[setterString substringFromIndex:3] lowercaseString];
    
    return [firHandleString substringToIndex:firHandleString.length-1];
}

-(void)addSetterMethodWithKeyPath:(NSString *)keyPath {
    
}
-(void)WPW_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
}
@end
