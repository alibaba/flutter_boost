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
#import "BoostMessageChannel.h"
#import "FLBFlutterContainerManager.h"
#import "FlutterBoostPlugin_private.h"
#import <objc/message.h>
#import <objc/runtime.h>

#define FLUTTER_APP [FlutterBoostPlugin sharedInstance].application
#define FLUTTER_VIEW FLUTTER_APP.flutterViewController.view
#define FLUTTER_VC FLUTTER_APP.flutterViewController

@interface FLBFlutterViewContainer  ()
@property (nonatomic,strong,readwrite) NSDictionary *params;
@property (nonatomic,assign) long long identifier;
@property (nonatomic, copy) NSString *flbNibName;
@property (nonatomic, strong) NSBundle *flbNibBundle;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation FLBFlutterViewContainer

- (instancetype)init
{
    [FLUTTER_APP.flutterProvider prepareEngineIfNeeded];
    if(self = [super initWithEngine:FLUTTER_APP.flutterProvider.engine
                            nibName:_flbNibName
                            bundle:_flbNibBundle]){
        //NOTES:在present页面时，默认是全屏，如此可以触发底层VC的页面事件。否则不会触发而导致异常
        self.modalPresentationStyle = UIModalPresentationFullScreen;

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
    return [self init];
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
 
    [BoostMessageChannel willShowPageContainer:^(NSNumber *result) {}
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
    [self.view setNeedsLayout];
    //instead of calling [super viewWillAppear:animated];, call super's super
//    struct objc_super target = {
//        .super_class = class_getSuperclass([FlutterViewController class]),
//        .receiver = self,
//    };
//    NSMethodSignature * (*callSuper)(struct objc_super *, SEL, BOOL animated) = (__typeof__(callSuper))objc_msgSendSuper;
//    callSuper(&target, @selector(viewWillAppear:), animated);
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
    
    //NOTES：务必在show之后再update，否则有闪烁
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
    
    //NOTES：因为UIViewController在present view后dismiss其页面的view disappear会发生在下一个页面view appear之后，从而让当前engine持有的vc inactive，此处可驱使其重新resume
    if (![self.uniqueIDString isEqualToString:[(FLBFlutterViewContainer*)FLUTTER_VC uniqueIDString]])
    {
        [FLUTTER_APP resume];
    }

}


- (void)viewDidDisappear:(BOOL)animated
{
    [BoostMessageChannel didDisappearPageContainer:^(NSNumber *result) {}
                                                pageName:_name
                                                  params:_params
                                                uniqueId:self.uniqueIDString];
    [super viewDidDisappear:animated];
    
    //NOTES:因为UIViewController在present view后dismiss其页面的view disappear会发生在下一个页面view appear之后，导致当前engine持有的VC被surfaceUpdate(NO)，从而销毁底层的raster。此处是考虑到这种情形，重建surface
    if (FLUTTER_VC.beingPresented || self.beingDismissed || ![self.uniqueIDString isEqualToString:[(FLBFlutterViewContainer*)FLUTTER_VC uniqueIDString]])
    {
        [FLUTTER_APP resume];
        [(FLBFlutterViewContainer*)FLUTTER_VC surfaceUpdated:YES];
    }

//  instead of calling [super viewDidDisappear:animated];, call super's super
//    struct objc_super target = {
//        .super_class = class_getSuperclass([FlutterViewController class]),
//        .receiver = self,
//    };
//    NSMethodSignature * (*callSuper)(struct objc_super *, SEL, BOOL animated) = (__typeof__(callSuper))objc_msgSendSuper;
//    callSuper(&target, @selector(viewDidDisappear:), animated);
    
    [self detatchFlutterEngine];
}

- (void)installSplashScreenViewIfNecessary {
    //Do nothing.
}

- (BOOL)loadDefaultSplashScreenView
{
    return NO;
}


@end
#pragma clang diagnostic pop
