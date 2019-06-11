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
#import "Service_NavigationService.h"
#import "FLBFlutterContainerManager.h"
#import "FlutterBoostPlugin_private.h"

#define FLUTTER_APP [FlutterBoostPlugin sharedInstance].application
#define FLUTTER_VIEW FLUTTER_APP.flutterViewController.view
#define FLUTTER_VC FLUTTER_APP.flutterViewController

@interface FLB2FlutterViewContainer  ()
@property (nonatomic,copy,readwrite) NSString *name;
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
        [self _setup];
    }
    return self;
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
//        [FLUTTER_APP resume];
    }
}

+ (void)instanceCounterDecrease
{
    kInstanceCounter--;
    if([self.class instanceCounter] == 0){
//        [FLUTTER_APP pause];
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
    [Service_NavigationService willDeallocPageContainer:^(NSNumber *r) {}
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
    if([FLUTTER_APP contains:self]){
        [self detatchFlutterEngine];
    }else{
        [self attatchFlutterEngine];
    }
  
    [FLUTTER_APP resume];
    
    [self surfaceUpdated:YES];
    //For new page we should attach flutter view in view will appear
    //for better performance.
 
    [Service_NavigationService willShowPageContainer:^(NSNumber *result) {}
                                            pageName:_name
                                              params:_params
                                            uniqueId:self.uniqueIDString];
    //Save some first time page info.
    if(![FlutterBoostPlugin sharedInstance].fPagename){
        [FlutterBoostPlugin sharedInstance].fPagename = _name;
        [FlutterBoostPlugin sharedInstance].fPageId = self.uniqueIDString;
        [FlutterBoostPlugin sharedInstance].fParams = _params;
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

- (void)installSplashScreenViewIfNecessary {
    //Do nothing.
}

- (BOOL)loadDefaultSplashScreenView
{
    return NO;
}


@end
