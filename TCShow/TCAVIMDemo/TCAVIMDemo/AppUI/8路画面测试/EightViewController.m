//
//  EightViewController.m
//  TCAVIMDemo
//
//  Created by AlexiChen on 16/7/14.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
#if kIsInnerTest
#import "EightViewController.h"


@implementation GridPreview

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _renderMap = [NSMutableDictionary dictionary];
        for (NSInteger i = 0 ; i < 9; i++)
        {
            [_renderMap setObject:@(NO) forKey:@(i)];
        }
    }
    return self;
}

- (void)getRenderRectFor:(id<AVMultiUserAble>)user
{
    for (NSInteger i = 0; i < 9; i++)
    {
        NSObject *ob = _renderMap[@(i)];
        if (![ob isKindOfClass:[NSString class]])
        {
            NSNumber *num = (NSNumber *)ob;
            if (!num.boolValue)
            {
                CGPoint sp = CGPointZero;
                CGSize size = CGSizeMake(self.bounds.size.width/3, self.bounds.size.height/3);
                sp.x += i%3 * size.width;
                sp.y += i/3 * size.height;
                [user setAvInteractArea:CGRectMake(sp.x, sp.y, size.width, size.height)];
                [_renderMap setObject:[user imUserId] forKey:@(i)];
                break;
            }
        }
        else
        {
            NSString *uid = (NSString *)ob;
            if ([[user imUserId] isEqualToString:uid])
            {
                CGPoint sp = CGPointZero;
                CGSize size = CGSizeMake(self.bounds.size.width/3, self.bounds.size.height/3);
                sp.x += i%3 * size.width;
                sp.y += i/3 * size.height;
                [user setAvInteractArea:CGRectMake(sp.x, sp.y, size.width, size.height)];
                [_renderMap setObject:[user imUserId] forKey:@(i)];

                break;
            }
        }
        
    }
}

- (void)addRenderFor:(id<AVMultiUserAble>)user
{
    [self getRenderRectFor:user];
    // 判断是否已添加
    if (user)
    {
        _imageView.frame = self.bounds;
        
        NSString *uid = [user imUserId];
        AVGLCustomRenderView *glView = (AVGLCustomRenderView *)[_imageView getSubviewForKey:uid];
        
        if (!glView)
        {
            glView = [[AVGLCustomRenderView alloc] initWithFrame:[user avInteractArea]];
            [_imageView addSubview:glView forKey:uid];
        }
        else
        {
            DebugLog(@"已存在的%@渲染画面，不重复添加", uid);
        }
        
        [glView setHasBlackEdge:NO];
        glView.nickView.hidden = YES;
        [glView setBoundsWithWidth:0];
        [glView setDisplayBlock:NO];
        [glView setCuttingEnable:YES];
        
        CGRect rect = [user avInteractArea];
        if (!CGRectIsEmpty(rect))
        {
            [glView setFrame:[user avInteractArea]];
        }
        
        if (![_imageView isDisplay])
        {
            [_imageView startDisplay];
        }
        
    }
}

- (void)removeRenderOf:(id<IMUserAble>)user
{
    [super removeRenderOf:user];
    
    for (NSInteger i = 0; i < 9; i++)
    {
        NSObject *ob = _renderMap[@(i)];
        if ([ob isKindOfClass:[NSString class]])
        {
            NSString *uid = (NSString *)ob;
            if ([[user imUserId] isEqualToString:uid])
            {
                [_renderMap setObject:@(NO) forKey:@(i)];
                break;
            }
        }
        
    }
}

@end


@implementation EightRoomEngine

- (NSString *)roomControlRole
{
    return @"EightGrid";
}

- (NSInteger)maxRequestViewCount
{
    if (_hasEnabelCamera)
    {
        return 7;
    }
    return 8;
}



@end

@interface EightViewController ()

@end

@implementation EightViewController

- (void)addLiveView
{
    // 子类重写
    UserAppBaseUIViewController *uivc = [[UserAppBaseUIViewController alloc] initWith:self];
    [self addChild:uivc inRect:self.view.bounds];
    
    _liveView = uivc;
}

- (void)addLivePreview
{
    GridPreview *preview = [[GridPreview alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:preview];
    _livePreview = preview;
    [_livePreview addRenderFor:[_roomInfo liveHost]];
}

- (void)createRoomEngine
{
    if (!_roomEngine)
    {
        id<AVMultiUserAble> ah = (id<AVMultiUserAble>)_currentUser;
        [ah setAvMultiUserState:_isHost ? AVMultiUser_Host : AVMultiUser_Guest];
        [ah setAvCtrlState:[self defaultAVHostConfig]];
        _roomEngine = [[EightRoomEngine alloc] initWith:(id<IMHostAble, AVMultiUserAble>)_currentUser enableChat:_enableIM];
        _roomEngine.delegate = self;
    }
}

- (NSInteger)defaultAVHostConfig
{
    return EAVCtrlState_All;
}

@end
#endif