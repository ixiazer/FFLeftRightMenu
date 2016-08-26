//
//  FFTabbarRIghtMenuManager.m
//  FreshFresh
//
//  Created by ixiazer on 16/4/12.
//  Copyright © 2016年 com.freshfresh. All rights reserved.
//

#import "FFTabbarRightMenuManager.h"
#import "RightMenuView.h"

// 屏幕宽度
#define FFScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define FFScreenHeight [UIScreen mainScreen].bounds.size.height


@interface FFTabbarRightMenuManager () <UIGestureRecognizerDelegate>
@property (nonatomic, copy) void(^rightMenuEventBlock)(FFRightMenuStatus status);
@property (nonatomic, strong) RightMenuView *rightMenuView;
@property (nonatomic, strong) UIView *coverBackView;
@property (nonatomic, assign) UIViewController *parentVC;
@property (nonatomic, assign) FFRightMenuStatus menuStatus;
@property (nonatomic, assign) FFRightMenuStatus panGusReadyMenuStatus;
@property (nonatomic, assign) CGFloat startX;
@property (nonatomic, assign) NSInteger rightMenuWidth;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer; // 左滑手势
@end

@implementation FFTabbarRightMenuManager

- (instancetype)init {
    if (self = [super init]) {
        self.rightMenuWidth = [[NSNumber numberWithFloat:FFScreenWidth-60] integerValue];
    }
    
    return self;
}

- (void)configWithParentVC:(id)parentVC rightMenuEventBlock:(void(^)(FFRightMenuStatus status))rightMenuEventBlock {
    self.rightMenuEventBlock = rightMenuEventBlock;
    self.parentVC = (UIViewController *)parentVC;

    UIView *rightSideView = [[UIView alloc] initWithFrame:CGRectMake(FFScreenWidth-20, 0, 30, FFScreenHeight)];
    rightSideView.backgroundColor = [UIColor clearColor];
    [self.parentVC.view addSubview:rightSideView];
    [rightSideView addGestureRecognizer:self.leftSwipeGestureRecognizer];
    
    self.menuStatus = FFRightMenuStatusForHide;
}

- (void)actionDrive:(FFRightMenuEvent)event {
    if (event == FFRightMenuEventForOpen) {
        if (!self.rightMenuView) {
            self.rightMenuView = [[RightMenuView alloc] initWithFrame:CGRectMake(FFScreenWidth, 0, self.rightMenuWidth, FFScreenHeight)];
            
//            __weak typeof(self) this = self;
//            self.rightMenuView.shipBackClose = ^() {
//                [this actionDrive:FFRightMenuEventForHide];
//            };
            
            UIPanGestureRecognizer *panGus = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesReceive:)];
            panGus.delegate = self;
            panGus.delaysTouchesBegan = YES;
            panGus.cancelsTouchesInView = NO;
            [self.rightMenuView addGestureRecognizer:panGus];
        }
        
        if (![self.rightMenuView isDescendantOfView:self.parentVC.view]) {
            [self.parentVC.view addSubview:self.rightMenuView];
        }

        CGFloat left = self.rightMenuView.frame.origin.x;
        if ([[NSNumber numberWithFloat:left] integerValue] == FFScreenWidth) {
            [self.parentVC.view insertSubview:self.coverBackView belowSubview:self.rightMenuView];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.coverBackView.alpha = 0.6;
                self.rightMenuView.frame = CGRectMake(FFScreenWidth-self.rightMenuWidth, 0, self.rightMenuWidth, FFScreenHeight);
            } completion:^(BOOL finished) {
                [self resetRightMenuStatus];
            }];
        }
    } else if (event == FFRightMenuEventForHide) {
        if (!self.rightMenuView) {
            return;
        }
        
        CGFloat right = self.rightMenuView.frame.origin.x+self.rightMenuView.frame.size.width;
        if ([[NSNumber numberWithFloat:right] integerValue] == FFScreenWidth) {
            [UIView animateWithDuration:0.3 animations:^{
                self.coverBackView.alpha = 0.0;
                self.rightMenuView.frame = CGRectMake(FFScreenWidth, 0, self.rightMenuWidth, FFScreenHeight);
            } completion:^(BOOL finished) {
                [self resetRightMenuStatus];
            }];
        }
    }
}

#pragma mark -- UIMethod
- (void)resetRightMenuStatus {
    NSInteger screenWidth = FFScreenWidth;
    if ([[NSNumber numberWithFloat:self.rightMenuView.frame.origin.x] integerValue] == screenWidth) {
        self.menuStatus = FFRightMenuStatusForHide;
        [self.rightMenuView removeFromSuperview];
        self.rightMenuView = nil;
        
        [self removeCoverView];
    } else {
        self.menuStatus = FFRightMenuStatusForShow;
    }
}

- (void)removeCoverView {
    [self.coverBackView removeFromSuperview];
    self.coverBackView = nil;
    
    if (self.rightMenuEventBlock) {
        self.rightMenuEventBlock(FFRightMenuStatusForHide);
    }
}

#pragma -mark UIGurstureDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.menuStatus == FFRightMenuStatusForMove) {
        return NO;
    }
    return YES;
}

#pragma mark UIGuesture method
- (void)rightMenuCoverTap:(UITapGestureRecognizer *)tap {
    if (self.rightMenuView.frame.origin.x+self.rightMenuView.frame.size.width == FFScreenWidth) {
        [UIView animateWithDuration:0.3 animations:^{
            self.menuStatus = FFRightMenuStatusForMove;
            self.coverBackView.alpha = 0.0;
            self.rightMenuView.frame = CGRectMake(FFScreenWidth, 0, self.rightMenuWidth, FFScreenHeight);
        } completion:^(BOOL finished) {
            [self resetRightMenuStatus];
        }];
    }
}

- (void)leftHandleSwipes:(UISwipeGestureRecognizer *)sender {
    [self actionDrive:FFRightMenuEventForOpen];
}

-(void)panGesReceive:(UIPanGestureRecognizer *)panGes {
    UIWindow *screenWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [panGes locationInView:screenWindow];
    
    if (panGes.state == UIGestureRecognizerStateBegan) {
        self.startX = panPoint.x;
        if (self.menuStatus != FFRightMenuStatusForShow) {
            // menu 在移动状态，不支持
            return;
        }
        self.panGusReadyMenuStatus = self.menuStatus;
    } else if (panGes.state == UIGestureRecognizerStateEnded || panGes.state == UIGestureRecognizerStateCancelled){
        if (self.panGusReadyMenuStatus == FFRightMenuStatusForShow) {
            CGFloat animateDistance = 0.0;
            CGFloat animateScale = 1.0;

            // 跟手势逻辑
            if (panPoint.x - self.startX <= 50 && panPoint.x - self.startX >= 0) {
                // 如果跟手向右滑动不超过50像素，则恢复原位
                animateDistance = 60;
                animateScale = fabs(panPoint.x - self.startX)/self.rightMenuWidth;
            } else if (panPoint.x - self.startX > 50) {
                animateDistance = FFScreenWidth;
                animateScale = fabs(self.rightMenuWidth - fabs(panPoint.x - self.startX))/self.rightMenuWidth;
            } else {
                self.rightMenuView.frame = CGRectMake(FFScreenWidth-self.rightMenuWidth, 0, self.rightMenuWidth, FFScreenHeight);
                self.menuStatus = FFRightMenuStatusForShow;
                
                return;
            }
            
            [UIView animateWithDuration:0.3*animateScale delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self moveLeftToX:animateDistance];
            } completion:^(BOOL finished) {
                [self resetRightMenuStatus];
            }];
        }
        return;
    }
    
    if (self.panGusReadyMenuStatus == FFRightMenuStatusForShow) {
        // 跟手势逻辑
        if (panPoint.x - self.startX <= 0) {
            return;
        } else {
            [self moveLeftToX:FFScreenWidth-self.rightMenuWidth+fabs(panPoint.x - self.startX)];
        }
    }

    return;
}

#pragma mark - Guesture method
- (void)moveLeftToX:(float)x {
    CGFloat scale;
    scale = 0.3*(self.rightMenuWidth-fabs(x))/self.rightMenuWidth;
    self.menuStatus = FFRightMenuStatusForMove;
    self.rightMenuView.frame = CGRectMake(x, 0, self.rightMenuWidth, FFScreenHeight);
    self.coverBackView.alpha = scale;
}

#pragma mark -- get method
- (UIView *)coverBackView {
    if (!_coverBackView) {
        _coverBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FFScreenWidth, FFScreenHeight)];
        _coverBackView.backgroundColor = [UIColor blackColor];
        _coverBackView.alpha = 0.0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightMenuCoverTap:)];
        tap.numberOfTapsRequired = 1;
        [_coverBackView addGestureRecognizer:tap];
    }
    return _coverBackView;
}

- (UISwipeGestureRecognizer *)leftSwipeGestureRecognizer {
    if (!_leftSwipeGestureRecognizer) {
        _leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftHandleSwipes:)];
        _leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    return _leftSwipeGestureRecognizer;
}

@end
