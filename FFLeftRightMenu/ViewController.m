//
//  ViewController.m
//  FFLeftRightMenu
//
//  Created by ixiazer on 16/8/26.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "ViewController.h"
#import "FFTabbarLeftMenuManager.h"
#import "FFTabbarRightMenuManager.h"

@interface ViewController ()
@property (nonatomic, strong) FFTabbarLeftMenuManager *leftMenuManager;
@property (nonatomic, strong) FFTabbarRightMenuManager *rightMenuManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self leftMenuConfig];
    [self rightMenuConfig];
    
    UIButton *leftMenuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftMenuBtn.frame = CGRectMake(0, 100, self.view.frame.size.width, 40);
    [leftMenuBtn addTarget:self action:@selector(leftMenu:) forControlEvents:UIControlEventTouchUpInside];
    [leftMenuBtn setTitle:@"leftMenu" forState:UIControlStateNormal];
    leftMenuBtn.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftMenuBtn];

    UIButton *rightMenuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightMenuBtn.frame = CGRectMake(0, 150, self.view.frame.size.width, 40);
    [rightMenuBtn addTarget:self action:@selector(rightMenu:) forControlEvents:UIControlEventTouchUpInside];
    [rightMenuBtn setTitle:@"rightMenu" forState:UIControlStateNormal];
    rightMenuBtn.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightMenuBtn];
}

- (void)leftMenu:(id)sender {
    [self.leftMenuManager actionDrive:FFLeftMenuEventForOpen];
}

- (void)rightMenu:(id)sender {
    [self.rightMenuManager actionDrive:FFRightMenuEventForOpen];
}

#pragma mark -- menu config
- (void)leftMenuConfig {
    [self.leftMenuManager configWithParentVC:self leftMenuEventBlock:^(FFLeftMenuStatus status) {
//        FFLog(@"left menu click");
    }];
}

- (void)rightMenuConfig {
    [self.rightMenuManager configWithParentVC:self rightMenuEventBlock:^(FFRightMenuStatus status) {
//        FFLog(@"right menu click");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - get method
- (FFTabbarLeftMenuManager *)leftMenuManager {
    if (!_leftMenuManager) {
        _leftMenuManager = [[FFTabbarLeftMenuManager alloc] init];
    }
    return _leftMenuManager;
}

- (FFTabbarRightMenuManager *)rightMenuManager {
    if (!_rightMenuManager) {
        _rightMenuManager = [[FFTabbarRightMenuManager alloc] init];
    }
    return _rightMenuManager;
}

@end
