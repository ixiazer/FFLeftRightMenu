//
//  FFTabbarLeftMenuManager.m
//  FreshFresh
//
//  Created by ixiazer on 16/4/13.
//  CopyLeft © 2016年 com.freshfresh. All Lefts reserved.
//

#import "FFTabbarLeftMenuManager.h"
#import "LeftMenuView.h"

// 屏幕宽度
#define FFScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define FFScreenHeight [UIScreen mainScreen].bounds.size.height


@interface FFTabbarLeftMenuManager () <UIGestureRecognizerDelegate>
@property (nonatomic, copy) void(^leftMenuEventBlock)(FFLeftMenuStatus status);
@property (nonatomic, strong) LeftMenuView *leftView;
@property (nonatomic, strong) UIView *coverBackView;
@property (nonatomic, assign) UIViewController *parentVC;
@property (nonatomic, assign) FFLeftMenuStatus menuStatus;
@property (nonatomic, assign) FFLeftMenuStatus panGusReadyMenuStatus;
@property (nonatomic, assign) CGFloat startX;

@property (nonatomic, assign) NSInteger leftMenuWidth;

@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer; // 左滑手势
@end

@implementation FFTabbarLeftMenuManager

- (instancetype)init {
    if (self = [super init]) {
        self.leftMenuWidth = [[NSNumber numberWithFloat:280] integerValue];
    }

    return self;
}

- (void)configWithParentVC:(id)parentVC leftMenuEventBlock:(void(^)(FFLeftMenuStatus status))leftMenuEventBlock {
    self.leftMenuEventBlock = leftMenuEventBlock;
    self.parentVC = parentVC;
    
    UIView *leftSideView = [[UIView alloc] initWithFrame:CGRectMake(-10, 0, 30, FFScreenHeight)];
    leftSideView.backgroundColor = [UIColor clearColor];
    [self.parentVC.view addSubview:leftSideView];
    [leftSideView addGestureRecognizer:self.rightSwipeGestureRecognizer];
    
    self.menuStatus = FFLeftMenuStatusForHide;
}

- (void)actionDrive:(FFLeftMenuEvent)event {
    if (event == FFLeftMenuEventForOpen) {
        if (!self.leftView) {
            self.leftView = [[LeftMenuView alloc] initWithFrame:CGRectMake(-self.leftMenuWidth, 0, self.leftMenuWidth, FFScreenHeight)];
            
            UIPanGestureRecognizer *panGus = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesReceive:)];
            panGus.delegate = self;
            panGus.delaysTouchesBegan = YES;
            panGus.cancelsTouchesInView = NO;
            [self.leftView addGestureRecognizer:panGus];
        }
        
        if (![self.leftView isDescendantOfView:self.parentVC.view]) {
            [self.parentVC.view addSubview:self.leftView];
        }

        if (self.leftView.frame.origin.x == -self.leftMenuWidth) {
            [self.parentVC.view insertSubview:self.coverBackView belowSubview:self.leftView];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.coverBackView.alpha = 0.6;
                self.leftView.frame = CGRectMake(0, 0, self.leftMenuWidth, FFScreenHeight);
            } completion:^(BOOL finished) {
                [self resetLeftMenuStatus];
            }];
        }
    } else if (event == FFLeftMenuEventForHide) {
        if (!self.leftView) {
            return;
        }
        
        if (self.leftView.frame.origin.x == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.coverBackView.alpha = 0.0;
                self.leftView.frame = CGRectMake(-self.leftMenuWidth, 0, self.leftMenuWidth, FFScreenHeight);
            } completion:^(BOOL finished) {
                [self resetLeftMenuStatus];
            }];
        }
    }
}

#pragma mark -- UIMethod
- (void)resetLeftMenuStatus {
    if (self.leftView.frame.origin.x == -self.leftMenuWidth) {
        self.menuStatus = FFLeftMenuStatusForHide;
        [self.leftView removeFromSuperview];
        self.leftView = nil;
        
        [self removeCoverView];
    } else {
        self.menuStatus = FFLeftMenuStatusForShow;
    }
}

- (void)removeCoverView {
    [self.coverBackView removeFromSuperview];
    self.coverBackView = nil;
    
    if (self.leftMenuEventBlock) {
        self.leftMenuEventBlock(FFLeftMenuStatusForHide);
    }
}

#pragma -mark UIGurstureDelegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.menuStatus == FFLeftMenuStatusForMove) {
        return NO;
    }
    return YES;
}

#pragma mark UIGuesture method
- (void)LeftMenuCoverTap:(UITapGestureRecognizer *)tap {
    if (self.leftView.frame.origin.x == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.menuStatus = FFLeftMenuStatusForMove;
            self.coverBackView.alpha = 0.0;
            self.leftView.frame = CGRectMake(-self.leftMenuWidth, 0, self.leftMenuWidth, FFScreenHeight);
        } completion:^(BOOL finished) {
            [self resetLeftMenuStatus];
        }];
    }
}

-(void)panGesReceive:(UIPanGestureRecognizer *)panGes {
    UIWindow *screenWindow = [UIApplication sharedApplication].delegate.window;
    CGPoint panPoint = [panGes locationInView:screenWindow];
    
    if (panGes.state == UIGestureRecognizerStateBegan) {
        self.startX = panPoint.x;
        if (self.menuStatus != FFLeftMenuStatusForShow) {
            // menu 在移动状态，不支持
            return;
        }
        self.panGusReadyMenuStatus = self.menuStatus;
    } else if (panGes.state == UIGestureRecognizerStateEnded || panGes.state == UIGestureRecognizerStateCancelled){
        if (self.panGusReadyMenuStatus == FFLeftMenuStatusForShow) {
            NSInteger animateDistance = 0.0;
            CGFloat animateScale = 1.0;
            // 跟手势逻辑
            if (panPoint.x - self.startX >= -50 && panPoint.x - self.startX <= 0) {
                // 如果跟手向右滑动不超过50像素，则恢复原位
                animateDistance = 0;
                animateScale =  fabs(panPoint.x - self.startX)/self.leftMenuWidth;
            } else if (panPoint.x - self.startX < -50) {
                animateDistance = -self.leftMenuWidth;
                animateScale =  fabs(self.leftMenuWidth-fabs(panPoint.x - self.startX))/self.leftMenuWidth;
            } else {
                self.leftView.frame = CGRectMake(0, 0, self.leftMenuWidth, FFScreenHeight);
                self.menuStatus = FFLeftMenuStatusForShow;

                return;
            }
            
            [UIView animateWithDuration:0.3*animateScale delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self moveLeftToX:animateDistance];
            } completion:^(BOOL finished) {
                [self resetLeftMenuStatus];
            }];
        }
        
        return;
    }
    
    if (self.panGusReadyMenuStatus == FFLeftMenuStatusForShow) {
        // 跟手势逻辑
        if (panPoint.x - self.startX >= 0) {
            return;
        } else {
            [self moveLeftToX:panPoint.x - self.startX];
        }
    }
    
    return;
}

#pragma mark - Guesture method
- (void)moveLeftToX:(float)x {
    CGFloat scale;
    scale = 0.3*(self.leftMenuWidth-fabs(x))/self.leftMenuWidth;
    self.menuStatus = FFLeftMenuStatusForMove;
    self.leftView.frame = CGRectMake(x, 0, self.leftMenuWidth, FFScreenHeight);
    self.coverBackView.alpha = scale;
}

- (void)rightHandleSwipes:(UISwipeGestureRecognizer *)sender {
    [self actionDrive:FFLeftMenuEventForOpen];
}

#pragma mark -- get method
- (UIView *)coverBackView {
    if (!_coverBackView) {
        _coverBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, FFScreenWidth, FFScreenHeight)];
        _coverBackView.backgroundColor = [UIColor blackColor];
        _coverBackView.alpha = 0.0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(LeftMenuCoverTap:)];
        tap.numberOfTapsRequired = 1;
        [_coverBackView addGestureRecognizer:tap];
    }
    return _coverBackView;
}


- (UISwipeGestureRecognizer *)rightSwipeGestureRecognizer {
    if (!_rightSwipeGestureRecognizer) {
        _rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightHandleSwipes:)];
        _rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _rightSwipeGestureRecognizer;
}

@end
