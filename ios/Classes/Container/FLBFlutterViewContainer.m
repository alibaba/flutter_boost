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

#define FLUTTER_VIEW [FLBFlutterApplication sharedApplication].flutterViewController.view
#define FLUTTER_VC [FLBFlutterApplication sharedApplication].flutterViewController
#define FLUTTER_APP [FLBFlutterApplication sharedApplication]

@interface FLBFlutterViewContainer  ()
@property (nonatomic,copy,readwrite) NSString *name;
@property (nonatomic,strong,readwrite) NSDictionary *params;
@property (nonatomic,strong) UIImageView *screenShotView;
@property (nonatomic,assign) long long identifier;
@property (nonatomic,assign) BOOL interactiveGestureActive;
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
        [[FLBStackCache sharedInstance] clear];
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
    if(self = [super init]){
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
     __weak typeof(self) weakSelf = self;
    if([notification.object isEqual: self.uniqueIDString]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showFlutterView];
        });
    }
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
    
    self.screenShotView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.screenShotView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.screenShotView];
}

#pragma mark - ScreenShots
- (UIImage *)takeScreenShot
{
    CGFloat scale = 1;
    switch ([FLBMemoryInspector.sharedInstance currentCondition]) {
        case FLBMemoryConditionNormal:
            scale = 2;
            break;
        case FLBMemoryConditionLowMemory:
            scale = 1;
            break;
        case FLBMemoryConditionExtremelyLow:
            scale = 0.75;
            break;
        case FLBMemoryConditionAboutToDie:
            return [UIImage new];
            break;
        case FLBMemoryConditionUnknown:
            if([[FLBMemoryInspector sharedInstance] smallMemoryDevice]){
                scale = 1;
            }else{
                scale = 2;
            }
            break;
    }
    
    self.screenShotView.opaque = YES;
    
    CGRect flutterBounds = self.view.bounds;
    CGSize snapshotSize = CGSizeMake(flutterBounds.size.width ,
                                     flutterBounds.size.height);
    UIGraphicsBeginImageContextWithOptions(snapshotSize, NO, scale);
    
    [self.view drawViewHierarchyInRect:flutterBounds
                    afterScreenUpdates:NO];
    
    UIImage *snapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return snapImage;
}

- (void)saveScreenShot
{
    UIImage *snapImage = [self takeScreenShot];
    if(snapImage){
        FLBStackCacheObjectImg *cImg = [[FLBStackCacheObjectImg alloc] initWithImage:snapImage];
        [[FLBStackCache sharedInstance] pushObject:cImg key:self.uniqueIDString];
    }
}

- (void)clearCurrentScreenShotImage
{
    self.screenShotView.image = nil;
}

- (UIImage *)getSavedScreenShot
{
    FLBStackCacheObjectImg *cImg = [[FLBStackCache sharedInstance] objectForKey:self.uniqueIDString];
    return [cImg image];
}

- (BOOL)isFlutterViewAttatched
{
    return FLUTTER_VIEW.superview == self.view;
}

- (void)attatchFlutterView
{
    if([self isFlutterViewAttatched]) return;
    
    [FLUTTER_VC willMoveToParentViewController:nil];
    [FLUTTER_VC removeFromParentViewController];
    [FLUTTER_VC didMoveToParentViewController:nil];
   
    [FLUTTER_VC willMoveToParentViewController:self];
    FLUTTER_VIEW.frame = self.view.bounds;
    
    if(!self.screenShotView.image){
         [self.view addSubview: FLUTTER_VIEW];
    }else{
        [self.view insertSubview:FLUTTER_VIEW belowSubview:self.screenShotView];
    }

    [self addChildViewController:FLUTTER_VC];
    [FLUTTER_VC didMoveToParentViewController:self];
}

- (BOOL)showSnapShotVew
{
    self.screenShotView.image = [self getSavedScreenShot];
   
    if([self isFlutterViewAttatched]){
        NSUInteger fIdx = [self.view.subviews indexOfObject:FLUTTER_VIEW];
        NSUInteger sIdx = [self.view.subviews indexOfObject:self.screenShotView];
        if(fIdx > sIdx){
            [self.view insertSubview:FLUTTER_VIEW
                             atIndex:0];
        }
    }else{
        
    }
    
    return self.screenShotView.image != nil;
}

- (void)showFlutterView
{
    if(FLUTTER_VIEW.superview != self.view) return;
    
    if([self isFlutterViewAttatched] ){
        NSUInteger fIdx = [self.view.subviews indexOfObject:FLUTTER_VIEW];
        NSUInteger sIdx = [self.view.subviews indexOfObject:self.screenShotView];
        self.screenShotView.backgroundColor = UIColor.clearColor;
        if(sIdx > fIdx){
            [self.view insertSubview:self.screenShotView belowSubview:FLUTTER_VIEW];
            [self flutterViewDidAppear:@{@"uid":self.uniqueIDString?:@""}];
        }
    }
    
    [self clearCurrentScreenShotImage];
    
    //Invalidate obsolete screenshot.
    [FLBStackCache.sharedInstance invalidate:self.uniqueIDString];
}

#pragma mark - Life circle methods

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [[FLBFlutterApplication sharedApplication] resume];
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.navigationController.interactivePopGestureRecognizer.state == UIGestureRecognizerStateBegan){
        self.interactiveGestureActive = true;
    }
    
    [[FLBFlutterApplication sharedApplication] resume];
    //For new page we should attach flutter view in view will appear
    //for better performance.
    if(![[FLBFlutterApplication sharedApplication] contains:self]){
         [self attatchFlutterView];
    }
    
    [self showSnapShotVew];
    
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
    [[FLBFlutterApplication sharedApplication] resume];
   
    //Ensure flutter view is attached.
    [self attatchFlutterView];
    
    [Service_NavigationService didShowPageContainer:^(NSNumber *result) {}
                                           pageName:_name
                                             params:_params
                                           uniqueId:self.uniqueIDString];
    
    [[FLBFlutterApplication sharedApplication] addUniqueViewController:self];
    
    [super viewDidAppear:animated];
 
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                 (int64_t)(2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),^{
                       if (weakSelf.isViewLoaded && weakSelf.view.window) {
                           // viewController is visible
                            [weakSelf showFlutterView];
                       }
                   });
    
    self.interactiveGestureActive = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    //is top.
    if([FLUTTER_APP isTop:self.uniqueIDString]
       && self.navigationController.interactivePopGestureRecognizer.state != UIGestureRecognizerStateBegan
       && !self.interactiveGestureActive){
        [self saveScreenShot];
    }
    
    self.interactiveGestureActive = NO;
   
    self.screenShotView.image = [self getSavedScreenShot];
    if(self.screenShotView.image){
        [self.view bringSubviewToFront:self.screenShotView];
    }
   
    [Service_NavigationService willDisappearPageContainer:^(NSNumber *result) {}
                                                 pageName:_name
                                                   params:_params
                                                 uniqueId:self.uniqueIDString];
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [Service_NavigationService didDisappearPageContainer:^(NSNumber *result) {}
                                                pageName:_name
                                                  params:_params
                                                uniqueId:self.uniqueIDString];
    
    [self clearCurrentScreenShotImage];
    [super viewDidDisappear:animated];

    [FLUTTER_APP inactive];
    self.interactiveGestureActive = NO;
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
