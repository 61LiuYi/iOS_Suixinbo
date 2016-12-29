//
//  TCAVSharedContext.m
//  TCShow
//
//  Created by AlexiChen on 16/5/24.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kIsUseAVSDKAsLiveScene
#import "TCAVSharedContext.h"

@interface TCAVSharedContext ()

@property (nonatomic, strong) QAVContext *sharedContext;

@end

@implementation TCAVSharedContext

static TCAVSharedContext *kSharedConext = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        kSharedConext = [[TCAVSharedContext alloc] init];
    });
    
    return kSharedConext;
}


+ (QAVContext *)sharedContext
{
    return [TCAVSharedContext sharedInstance].sharedContext;
}

+ (void)configWithStartedContext:(QAVContext *)context
{
    if ([TCAVSharedContext sharedInstance].sharedContext)
    {
        [TCAVSharedContext destroyContextCompletion:^{
            [TCAVSharedContext sharedInstance].sharedContext = context;
        }];
    }
    else
    {
        [TCAVSharedContext sharedInstance].sharedContext = context;
    }
    
}

+ (void)configWithStartedContext:(id<IMHostAble>)host completion:(CommonFinishBlock)block
{
    if ([TCAVSharedContext sharedInstance].sharedContext == nil)
    {
        QAVContextStartParam *config = [[QAVContextStartParam alloc] init];
        
        NSString *appid = [host imSDKAppId];
        
        config.sdkAppId = [appid intValue];
        config.appidAt3rd = appid;
        config.identifier = [host imUserId];
        config.accountType = [host imSDKAccountType];
        config.engineCtrlType = QAVSpearEngineCtrlTypeCloud;
        QAVContext *context = [QAVContext CreateContext];
        
        [context startWithParam:config completion:^(int result, NSString *errorInfo) {
            
            DebugLog(@"共享的QAVContext = %p result = %d error = %@", context, (int)result, errorInfo);
            if (result == QAV_OK)
            {
                [TCAVSharedContext sharedInstance].sharedContext = context;
            }
            
            if (block)
            {
                block(result == QAV_OK);
            }
        }];
    }
}

+ (void)destroyContextCompletion:(CommonVoidBlock)block
{
    if ([TCAVSharedContext sharedInstance].sharedContext)
    {
        QAVResult res = [[TCAVSharedContext sharedInstance].sharedContext stop];
        if (res != QAV_OK)
        {
            DebugLog(@"stopContext失败 result = %d", (int)res);
        }
        [[TCAVSharedContext sharedInstance].sharedContext destroy];
        [TCAVSharedContext sharedInstance].sharedContext = nil;
        if (block)
        {
            block();
        }
    }
}

@end
#endif
