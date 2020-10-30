//
//  ViewController.m
//  CustomizeKVO
//
//  Created by MacW on 2020/10/30.
//

#import "ViewController.h"
#import "NextViewController.h"
#import "WPWPerson.h"
@interface ViewController ()



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableSet *set = [NSMutableSet set];
    
    WPWPerson *person = [[WPWPerson alloc] init];
    person.name = @"KC";
    person.nickName = @"nickName";
    [set addObject:person];
    
    WPWPerson *person2 = [[WPWPerson alloc] init];
    person2.name = @"KC";
    person2.nickName = @"nickName";
    
   WPWPerson *info = [set member:person2];
    if (info) {
        NSLog(@"存在");
    }else {
        NSLog(@"不存在");

    }
}

- (IBAction)push:(id)sender {
    [self.navigationController pushViewController:[NextViewController new] animated:YES];
}



@end
