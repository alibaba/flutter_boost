/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2019 Alibaba Group
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "FLBFlutterApplication.h"
#import "FlutterBoost.h"
#import "FLBFlutterViewContainerManager.h"
#import "FLBViewProviderFactory.h"

@interface FLBFlutterApplication()
@property (nonatomic,strong) FLBFlutterViewContainerManager *manager;
@property (nonatomic,strong) id<FLBFlutterViewProvider> viewProvider;

@property (nonatomic,strong) NSMutableDictionary *pageBuilders;
@property (nonatomic,copy) FLBPageBuilder defaultPageBuilder;
@property (nonatomic,assign) BOOL isRendering;
@property (nonatomic,assign) BOOL isRunning;
@end


@implementation FLBFlutterApplication

+ (FLBFlutterApplication *)sharedApplication
{
    static FLBFlutterApplication *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (BOOL)isRunning
{
    return _isRunning;
}

- (void)startFlutterWithPlatform:(id<FLBPlatform>)platform
                         onStart:(void (^)(FlutterViewController * _Nonnull))callback
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.platform = platform;
        self.viewProvider = [[FLBViewProviderFactory new] createViewProviderWithPlatform:platform];
        [self.viewProvider resume];
        self.isRendering = YES;
        self.isRunning = YES;
        if(callback) callback(self.viewProvider.viewController);
    });
}

- (instancetype)init
{
    if (self = [super init]) {
        _manager = [FLBFlutterViewContainerManager new];
        _pageBuilders = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)flutterView
{
    return [self flutterViewController].view;
}

- (FlutterViewController *)flutterViewController
{
    return self.viewProvider.viewController;
}


- (BOOL)contains:(FLBFlutterViewContainer  *)vc
{
    return [_manager contains:vc];
}

- (void)addUniqueViewController:(FLBFlutterViewContainer  *)vc
{
    return [_manager addUnique:vc];
}

- (void)removeViewController:(FLBFlutterViewContainer  *)vc
{
    return [_manager remove:vc];
}


- (BOOL)isTop:(NSString *)pageId
{
    return [_manager.peak isEqual:pageId];
}

- (void)pause
{
    if(!_isRendering) return;
    
    [self.viewProvider pause];
    
    _isRendering = NO;
    
}

- (void)resume
{
    if(_isRendering) return;
    
    [self.viewProvider resume];
    
    _isRendering = YES;
    
}

- (void)inactive
{
    [self.viewProvider inactive];
}

- (void)setAccessibilityEnable:(BOOL)enable
{
    [self.viewProvider setAccessibilityEnable:enable];
}


@end
