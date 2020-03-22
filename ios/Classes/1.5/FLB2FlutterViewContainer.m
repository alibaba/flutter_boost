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

#import "FLB2FlutterViewContainer.h"
#import "FLB2FlutterApplication.h"
#import "BoostMessageChannel.h"
#import "FLB2FlutterContainerManager.h"
#import "FlutterBoostPlugin2_private.h"

#define FLUTTER_APP [FlutterBoostPlugin2 sharedInstance].application
#define FLUTTER_VIEW FLUTTER_APP.flutterViewController.view
#define FLUTTER_VC FLUTTER_APP.flutterViewController

@interface FlutterViewController (bridgeToviewDidDisappear)
- (void)flushOngoingTouches;
- (void)bridge_viewDidDisappear:(BOOL)animated;
- (void)bridge_viewWillAppear:(BOOL)animated;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation FlutterViewController (bridgeToviewDidDisappear)
- (void)bridge_viewDidDisappear:(BOOL)animated{
//    TRACE_EVENT0("flutter", "viewDidDisappear");
    [self flushOngoingTouches];

    [super viewDidDisappear:animated];
}

- (void)bridge_viewWillAppear:(BOOL)animated{
//    TRACE_EVENT0("flutter", "viewWillAppear");

//    if (_engineNeedsLaunch) {
//      [_engine.get() launchEngine:nil libraryURI:nil];
//      [_engine.get() setViewController:self];
//      _engineNeedsLaunch = NO;
//    }
    [FLUTTER_APP inactive];
    
    [super viewWillAppear:animated];
}
@end
#pragma pop

@interface FLB2FlutterViewContainer  ()
@property (nonatomic,strong,readwrite) NSDictionary *params;
@property (nonatomic,assign) long long identifier;
@end

@implementation FLB2FlutterViewContainer

- (instancetype)init
{
    [FLUTTER_APP.flutterProvider prepareEngineIfNeeded];
    if(self = [super initWithEngine:FLUTTER_APP.flutterProvider.engine
                            nibName:nil
                             bundle:nil]){
        //NOTES:在present页面时，默认是全屏，如此可以触发底层VC的页面事件。否则不会触发而导致异常
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        [self _setup];
    }
    return self;
}

- (instancetype)initWithProject:(FlutterDartProject*)projectOrNil
                        nibName:(NSString*)nibNameOrNil
                         bundle:(NSBundle*)nibBundleOrNil {
    NSAssert(NO, @"unsupported init method!");
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder: aDecoder]) {
        NSAssert(NO, @"unsupported init method!");
        [self _setup];
    }
    return self;
}

- (void)setName:(NSString *)name params:(NSDictionary *)params
{
    if(!_name && name){
        _name = name;
        _params = params;
        [BoostMessageChannel didInitPageContainer:^(NSNumber *r) {}
                                               pageName:name
                                                 params:params
                                               uniqueId:[self uniqueIDString]];
    }
}


static NSUInteger kInstanceCounter = 0;

+ (NSUInteger)instanceCounter
{
    return kInstanceCounter;
}

+ (void)instanceCounterIncrease
{
    kInstanceCounter++;
    if(kInstanceCounter == 1){
        [FLUTTER_APP resume];
    }
}

+ (void)instanceCounterDecrease
{
    kInstanceCounter--;
    if([self.class instanceCounter] == 0){
        [FLUTTER_APP pause];
    }
}

- (NSString *)uniqueIDString
{
    return @(_identifier).stringValue;
}

- (void)_setup
{
    static long long sCounter = 0;
    _identifier = sCounter++;
    [self.class instanceCounterIncrease];
}

- (void)dealloc
{
    [self notifyWillDealloc];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)notifyWillDealloc
{
    [BoostMessageChannel willDeallocPageContainer:^(NSNumber *r) {}
                                               pageName:_name params:_params
                                               uniqueId:[self uniqueIDString]];

    [FLUTTER_APP removeViewController:self];
    
    [self.class instanceCounterDecrease];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

#pragma mark - ScreenShots
- (BOOL)isFlutterViewAttatched
{
    return FLUTTER_VIEW.superview == self.view;
}

- (void)attatchFlutterEngine
{
    [FLUTTER_APP.flutterProvider prepareEngineIfNeeded];
    [FLUTTER_APP.flutterProvider atacheToViewController:self];
}

- (void)detatchFlutterEngine
{
    [FLUTTER_APP.flutterProvider detach];
}

#pragma mark - Life circle methods

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [FLUTTER_APP resume];
}

- (void)viewWillAppear:(BOOL)animated
{
    //For new page we should attach flutter view in view will appear
    //for better performance.

    [self attatchFlutterEngine];

    [BoostMessageChannel willShowPageContainer:^(NSNumber *result) {}
                                            pageName:_name
                                              params:_params
                                            uniqueId:self.uniqueIDString];
    //Save some first time page info.
    if(![FlutterBoostPlugin2 sharedInstance].fPagename){
        [FlutterBoostPlugin2 sharedInstance].fPagename = _name;
        [FlutterBoostPlugin2 sharedInstance].fPageId = self.uniqueIDString;
        [FlutterBoostPlugin2 sharedInstance].fParams = _params;
    }
    
    [super bridge_viewWillAppear:animated];
    [self.view setNeedsLayout];//TODO:通过param来设定
}

- (void)viewDidAppear:(BOOL)animated
{
    [FLUTTER_APP addUniqueViewController:self];
    
    //Ensure flutter view is attached.
    [self attatchFlutterEngine];
 
    [BoostMessageChannel didShowPageContainer:^(NSNumber *result) {}
                                           pageName:_name
                                             params:_params
                                           uniqueId:self.uniqueIDString];
    //NOTES：务必在show之后再update，否则有闪烁; 或导致侧滑返回时上一个页面会和top页面内容一样
    [self surfaceUpdated:YES];

    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [BoostMessageChannel willDisappearPageContainer:^(NSNumber *result) {}
                                                 pageName:_name
                                                   params:_params
                                                 uniqueId:self.uniqueIDString];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [BoostMessageChannel didDisappearPageContainer:^(NSNumber *result) {}
                                                pageName:_name
                                                  params:_params
                                                uniqueId:self.uniqueIDString];
    //如果当前不可见vc和engine所持有的vc一致。在FlutterVC在混合栈中是最后一张页面，如tab中的页面
    if (self == FLUTTER_VC)
    {
        [self surfaceUpdated:NO];
        [self detatchFlutterEngine];
    }
    [super bridge_viewDidDisappear:animated];
}

- (void)installSplashScreenViewIfNecessary {
    //Do nothing.
}

- (BOOL)loadDefaultSplashScreenView
{
    return NO;
}


@end
