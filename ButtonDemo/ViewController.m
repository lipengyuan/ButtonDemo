//
//  ViewController.m
//  ButtonDemo
//
//  Created by River on 15/6/11.
//  Copyright (c) 2015年 lipengyuan. All rights reserved.
//

#import "ViewController.h"
#import "HamburgerButton.h"

@interface ViewController ()
{
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    // Do any additional setup after loading the view, typically from a nib.
    HamburgerButton *itemBtn = [[HamburgerButton alloc]initWithFrame:CGRectMake(100, 100, 50,50)];
    [itemBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:itemBtn];
    
}

-(void)click:(HamburgerButton *)btn{
    btn.showMenu = !btn.showMenu;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
