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

#import "FLBFlutterViewContainer.h"
#import "FLBFlutterApplication.h"
#import "FLBStackCache.h"
#import "FLBStackCacheObjectImg.h"
#import "FLBMemoryInspector.h"
#import "Service_NavigationService.h"
#import "FlutterBoostConfig.h"
#import "FLBFlutterViewContainerManager.h"

#define FLUTTER_VIEW [FLBFlutterApplication sharedApplication].flutterViewController.view
#define FLUTTER_VC [FLBFlutterApplication sharedApplication].flutterViewController
#define FLUTTER_APP [FLBFlutterApplication sharedApplication]

@interface FLBFlutterViewContainer  ()
@property (nonatomic,copy,readwrite) NSString *name;
@property (nonatomic,strong,readwrite) NSDictionary *params;
@property (nonatomic,assign) long long identifier;
@end

@implementation FLBFlutterViewContainer

- (void)setName:(NSString *)name params:(NSDictionary *)params
{
    if(!_name && name){
        _name = name;
        _params = params;
        [Service_NavigationService didInitPageContainer:^(NSNumber *r) {}
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
        [[FLBFlutterApplication sharedApplication] pause];
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
    
    SEL sel = @selector(flutterViewDidShow:);
    NSString *notiName = @"flutter_boost_container_showed";
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:sel
                                               name:notiName
                                             object:nil];
}

- (instancetype)init
{
    [FLUTTER_APP.flutterProvider prepareEngineIfNeeded];
    if(self = [super initWithEngine:FLUTTER_APP.flutterProvider.engine
                            nibName:nil
                             bundle:nil]){
        [self _setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder: aDecoder]) {
        [self _setup];
    }
    return self;
}

- (void)flutterViewDidAppear:(NSDictionary *)params
{
    //Notify flutter view appeared.
}

- (void)flutterViewDidShow:(NSNotification *)notification
{
   
}

- (void)dealloc
{
    [self notifyWillDealloc];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)notifyWillDealloc
{
    [Service_NavigationService willDeallocPageContainer:^(NSNumber *r) {}
                                               pageName:_name params:_params
                                               uniqueId:[self uniqueIDString]];

    [[FLBStackCache sharedInstance] remove:self.uniqueIDString];
    [[FLBFlutterApplication sharedApplication] removeViewController:self];
    
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
//    [FLUTTER_APP.flutterProvider prepareEngineIfNeeded];
    [FLUTTER_APP.flutterProvider detach];
}


#pragma mark - Life circle methods

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [[FLBFlutterApplication sharedApplication] resume];
}

- (void)viewWillAppear:(BOOL)animated
{
    if([FLUTTER_APP contains:self]){
        [self detatchFlutterEngine];
    }else{
        [self attatchFlutterEngine];
    }
  
    [[FLBFlutterApplication sharedApplication] resume];
    
    [self surfaceUpdated:YES];
    //For new page we should attach flutter view in view will appear
    //for better performance.
 
    [Service_NavigationService willShowPageContainer:^(NSNumber *result) {}
                                            pageName:_name
                                              params:_params
                                            uniqueId:self.uniqueIDString];
    //Save some first time page info.
    if(![FlutterBoostConfig sharedInstance].fPagename){
        [FlutterBoostConfig sharedInstance].fPagename = _name;
        [FlutterBoostConfig sharedInstance].fPageId = self.uniqueIDString;
        [FlutterBoostConfig sharedInstance].fParams = _params;
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [FLUTTER_APP addUniqueViewController:self];
    
    //Ensure flutter view is attached.
    [self attatchFlutterEngine];
    [self surfaceUpdated:YES];
    [Service_NavigationService didShowPageContainer:^(NSNumber *result) {}
                                           pageName:_name
                                             params:_params
                                           uniqueId:self.uniqueIDString];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [Service_NavigationService willDisappearPageContainer:^(NSNumber *result) {}
                                                 pageName:_name
                                                   params:_params
                                                 uniqueId:self.uniqueIDString];
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [self detatchFlutterEngine];
    [Service_NavigationService didDisappearPageContainer:^(NSNumber *result) {}
                                                pageName:_name
                                                  params:_params
                                                uniqueId:self.uniqueIDString];
    [super viewDidDisappear:animated];
}

#pragma mark - FLBViewControllerResultHandler
- (void)onRecievedResult:(NSDictionary *)resultData forKey:(NSString *)key
{
    [Service_NavigationService onNativePageResult:^(NSNumber *finished) {}
                                         uniqueId:self.uniqueIDString
                                              key:key
                                       resultData:resultData
                                           params:@{}];
}


@end
