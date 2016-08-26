//
//  FFTabbarRIghtMenuManager.h
//  FreshFresh
//
//  Created by ixiazer on 16/4/12.
//  Copyright © 2016年 com.freshfresh. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FFRightMenuEvent) {
    FFRightMenuEventForOpen = 1 << 0, // 显示
    FFRightMenuEventForHide = 1 << 1, // 关闭
};

typedef NS_ENUM(NSInteger, FFRightMenuStatus) {
    FFRightMenuStatusForShow = 1 << 0, // 显示
    FFRightMenuStatusForHide = 1 << 1, // 关闭
    FFRightMenuStatusForMove = 1 << 2 // 移动
};

@interface FFTabbarRightMenuManager : NSObject

- (void)configWithParentVC:(id)parentVC rightMenuEventBlock:(void(^)(FFRightMenuStatus status))rightMenuEventBlock;

- (void)actionDrive:(FFRightMenuEvent)event;

@end
