//
//  NextViewController.m
//  CustomizeKVO
//
//  Created by MacW on 2020/10/30.
//

#import "NextViewController.h"
#import "WPWPerson.h"
#import "NSObject+WPW.h"

@interface NextViewController ()

@property (nonatomic, strong) WPWPerson *person;

@end

@implementation NextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.person = [WPWPerson new];
    self.person.name = @"wpw";
//    [self.person WPW_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    [self.person WPW_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew block:^(id  _Nonnull observer, NSString * _Nonnull keyPath, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        NSLog(@"%@----",change);

    }];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.person.name = [NSString stringWithFormat:@"%@+",self.person.name];
}
-(void)WPW_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@",change);
}

-(void)dealloc {
    
}

@end
