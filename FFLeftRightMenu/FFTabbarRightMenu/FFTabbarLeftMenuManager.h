//
//  FFTabbarLeftMenuManager.h
//  FreshFresh
//
//  Created by ixiazer on 16/4/13.
//  Copyright © 2016年 com.freshfresh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FFLeftMenuEvent) {
    FFLeftMenuEventForOpen = 1 << 0, // 显示
    FFLeftMenuEventForHide = 1 << 1, // 关闭
};

typedef NS_ENUM(NSInteger, FFLeftMenuStatus) {
    FFLeftMenuStatusForShow = 1 << 0, // 显示
    FFLeftMenuStatusForHide = 1 << 1, // 关闭
    FFLeftMenuStatusForMove = 1 << 2 // 移动
};

@interface FFTabbarLeftMenuManager : NSObject

- (void)configWithParentVC:(id)parentVC leftMenuEventBlock:(void(^)(FFLeftMenuStatus status))leftMenuEventBlock;

- (void)actionDrive:(FFLeftMenuEvent)event;

@end
