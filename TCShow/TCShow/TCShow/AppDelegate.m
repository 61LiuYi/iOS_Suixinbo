//
//  AppDelegate.m
//  TCShow
//
//  Created by AlexiChen on 16/4/11.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "AppDelegate.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


+ (instancetype)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void)configAppLaunch
{
    [IMAPlatform configHostClass:[TCShowHost class]];
    [[NSClassFromString(@"UICalloutBarButton") appearance] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#if kIsIMAAppFromBase

#else
// 一般用户自己App都会重写该方法
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configAppLaunch];
    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}
#endif

- (void)enterMainUI
{
    NSNumber *has = [[NSUserDefaults standardUserDefaults] objectForKey:@"HasReadUserProtocol"];
    if (!has || !has.boolValue)
    {
        UserProtocolViewController *vc = [[UserProtocolViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nav;
        return;
    }
    
    self.window.rootViewController = [[TarBarController alloc] init];
    
    if (!_resotreLiveParam)
    {
        _resotreLiveParam = [[TCShowLiveListItem alloc] init];
    }
    //获取恢复房间参数
    //延迟1秒,是为了等待登录成功之后配置好host的值。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        TCShowLiveListItem *item = [TCShowLiveListItem loadFromToLocal];
        if (item)
        {
            UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"是否恢复上次直播间" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1)
                {
                    _resotreLiveParam = item;
#if kSupportMultiLive
                    TCShowMultiLiveViewController *vc = [[TCShowMultiLiveViewController alloc] initWith:item user:[IMAPlatform sharedInstance].host];
                    [[AppDelegate sharedAppDelegate] pushViewController:vc];
#else
                    TCShowLiveViewController *vc = [[TCShowLiveViewController alloc] initWith:item user:[IMAPlatform sharedInstance].host];
                    [[AppDelegate sharedAppDelegate] pushViewController:vc];
#endif
                }
            }];
            [alert show];
        }
    });
    
}
@end
