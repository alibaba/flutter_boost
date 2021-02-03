//
//  FBFlutterViewContainer.h
//  Pods
//
//  Created by wubian on 2021/1/27.
//
#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>
#import "FBFlutterContainer.h"

@interface FBFlutterViewContainer  : FlutterViewController<FBFlutterContainer>

@property (nonatomic,copy,readwrite) NSString *name;
@property (nonatomic, strong) NSNumber *disablePopGesture;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (void)surfaceUpdated:(BOOL)appeared;

@end


