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

#import <Foundation/Foundation.h>
#import "FBFlutterViewContainer.h"
#import "FlutterBoost.h"
#import "FBLifecycle.h"
#import <objc/message.h>
#import <objc/runtime.h>

#define ENGINE [[FlutterBoost instance] engine]
#define FB_PLUGIN  [FlutterBoostPlugin getPlugin: [[FlutterBoost instance] engine]]



#define weakify(var) ext_keywordify __weak typeof(var) O2OWeak_##var = var;
#define strongify(var) ext_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = O2OWeak_##var; \
_Pragma("clang diagnostic pop")
#if DEBUG
#   define ext_keywordify autoreleasepool {}
#else
#   define ext_keywordify try {} @catch (...) {}
#endif



@interface FlutterViewController (bridgeToviewDidDisappear)
- (void)flushOngoingTouches;
- (void)bridge_viewDidDisappear:(BOOL)animated;
- (void)bridge_viewWillAppear:(BOOL)animated;
- (void)surfaceUpdated:(BOOL)appeared;
- (void)updateViewportMetrics;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation FlutterViewController (bridgeToviewDidDisappear)
- (void)bridge_viewDidDisappear:(BOOL)animated{
    [self flushOngoingTouches];
    [super viewDidDisappear:animated];
}
- (void)bridge_viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
@end
#pragma pop

@interface FBFlutterViewContainer ()
@property (nonatomic,strong,readwrite) NSDictionary *params;
@property (nonatomic,copy) NSString *uniqueId;
@property (nonatomic, copy) NSString *flbNibName;
@property (nonatomic, strong) NSBundle *flbNibBundle;
@property(nonatomic, assign) BOOL opaque;
@property (nonatomic, strong) FBVoidCallback removeEventCallback;
@end

@implementation FBFlutterViewContainer

- (instancetype)init
{
    ENGINE.viewController = nil;
    if(self = [super initWithEngine:ENGINE
                            nibName:_flbNibName
                             bundle:_flbNibBundle]){
        //NOTES:在present页面时，默认是全屏，如此可以触发底层VC的页面事件。否则不会触发而导致异常
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        [self _setup];
    }
    return self;
}

- (instancetype)initWithProject:(FlutterDartProject*)projectOrNil
                        nibName:(NSString*)nibNameOrNil
                         bundle:(NSBundle*)nibBundleOrNil  {
    ENGINE.viewController = nil;
    if (self = [super initWithProject:projectOrNil nibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self _setup];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder: aDecoder]) {
        NSAssert(NO, @"unsupported init method!");
        [self _setup];
    }
    return self;
}
#pragma pop

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    _flbNibName = nibNameOrNil;
    _flbNibBundle = nibBundleOrNil;
    ENGINE.viewController = nil;
    return [self init];
}

- (void)setName:(NSString *)name uniqueId:(NSString *)uniqueId params:(NSDictionary *)params opaque:(BOOL) opaque
{
    if(!_name && name){
        _name = name;
        _params = params;
        _opaque = opaque;
        //
        //这里如果是不透明的情况，才将viewOpaque 设为false，
        //并且才将modalStyle设为UIModalPresentationOverFullScreen
        //因为UIModalPresentationOverFullScreen模式下，下面的vc重新显示的时候不会
        //调用viewAppear相关生命周期,所以需要手动调用beginAppearanceTransition相关方法来触发
        //
        if(!_opaque){
            self.viewOpaque = opaque;
            self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        }
        if (uniqueId != nil) {
            _uniqueId = uniqueId;
        }
    }
    [FB_PLUGIN containerCreated:self];
    
    /// 设置这个container对应的从flutter过来的事件监听
    [self setupEventListeningFromFlutter];
}

/// 设置这个container对应的从flutter过来的事件监听
-(void)setupEventListeningFromFlutter{
    @weakify(self)
    // 为这个容器注册监听，监听内部的flutterPage往这个容器发的事件
    self.removeEventCallback = [FlutterBoost.instance addEventListener:^(NSString *name, NSDictionary *arguments) {
        @strongify(self)
        //事件名
        NSString *event = arguments[@"event"];
        //事件参数
        NSDictionary *args = arguments[@"args"];
        
        if ([event isEqualToString:@"enablePopGesture"]) {
            // 多page情况下的侧滑动态禁用和启用事件
            NSNumber *enableNum = args[@"enable"];
            BOOL enable = [enableNum boolValue];
            self.navigationController.interactivePopGestureRecognizer.enabled = enable;
        }
    } forName:self.uniqueId];
}

- (NSString *)uniqueIDString {
    return self.uniqueId;
}

- (void)_setup {
    self.uniqueId = [[NSUUID UUID] UUIDString];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        //当VC被移出parent时，就通知flutter层销毁page
        [self detachFlutterEngineIfNeeded];
        [self notifyWillDealloc];
    }
    [super didMoveToParentViewController:parent];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [super dismissViewControllerAnimated:flag completion:^(){
        if (completion) {
            completion();
        }
        //当VC被dismiss时，就通知flutter层销毁page
        [self detachFlutterEngineIfNeeded];
        [self notifyWillDealloc];
    }];
}

- (void)dealloc
{
    if(self.removeEventCallback != nil){
        self.removeEventCallback();
    }
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)notifyWillDealloc
{
    [FB_PLUGIN containerDestroyed:self];
}

- (void)viewDidLoad {
    // Ensure current view controller attach to Flutter engine
    [self attatchFlutterEngine];
    
    [super viewDidLoad];
    //只有在不透明情况下，才设置背景颜色，否则不设置颜色（也就是默认透明）
    if(self.opaque){
        self.view.backgroundColor = UIColor.whiteColor;
    }
}

#pragma mark - ScreenShots
- (BOOL)isFlutterViewAttatched
{
    return ENGINE.viewController.view.superview == self.view;
}

- (void)attatchFlutterEngine
{
    if(ENGINE.viewController != self){
        ENGINE.viewController=self;
    }
}

- (void)detachFlutterEngineIfNeeded
{
    if (self.engine.viewController == self) {
        //need to call [surfaceUpdated:NO] to detach the view controller's ref from
        //interal engine platformViewController,or dealloc will not be called after controller close.
        //detail:https://github.com/flutter/engine/blob/07e2520d5d8f837da439317adab4ecd7bff2f72d/shell/platform/darwin/ios/framework/Source/FlutterViewController.mm#L529
        [self surfaceUpdated:NO];
        
        if(ENGINE.viewController != nil) {
            ENGINE.viewController = nil;
        }
    }
}

- (void)surfaceUpdated:(BOOL)appeared {
    if (self.engine && self.engine.viewController == self) {
        [super surfaceUpdated:appeared];
    }
}

- (void)updateViewportMetrics {
    if (self.engine && self.engine.viewController == self) {
        [super updateViewportMetrics];
    }
}

#pragma mark - Life circle methods

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [FB_PLUGIN containerWillAppear:self];
    //For new page we should attach flutter view in view will appear
    //for better performance.
    [self attatchFlutterEngine];
    
    [super bridge_viewWillAppear:animated];
    [self.view setNeedsLayout];//TODO:通过param来设定
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //Ensure flutter view is attached.
    [self attatchFlutterEngine];
    
    //根据淘宝特价版日志证明，即使在UIViewController的viewDidAppear下，application也可能在inactive模式，此时如果提交渲染会导致GPU后台渲染而crash
    //参考：https://github.com/flutter/flutter/issues/57973
    //https://github.com/flutter/engine/pull/18742
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        //NOTES：务必在show之后再update，否则有闪烁; 或导致侧滑返回时上一个页面会和top页面内容一样
        [self surfaceUpdated:YES];
        
    }
    [super viewDidAppear:animated];
    
    // Enable or disable pop gesture
    // note: if disablePopGesture is nil, do nothing
    if (self.disablePopGesture) {
        self.navigationController.interactivePopGestureRecognizer.enabled = ![self.disablePopGesture boolValue];
    }
    [FB_PLUGIN containerAppeared:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super bridge_viewDidDisappear:animated];
    [FB_PLUGIN containerDisappeared:self];
}

- (void)installSplashScreenViewIfNecessary {
    //Do nothing.
}

- (BOOL)loadDefaultSplashScreenView
{
    return YES;
}

@end

