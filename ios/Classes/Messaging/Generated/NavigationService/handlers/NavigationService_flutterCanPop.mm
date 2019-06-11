//
//  NavigationService_canPop.m
//  flutter_boost
//
//  Created by ZhongCheng Guo on 2019/6/5.
//

#import "NavigationService_flutterCanPop.h"
#import "ServiceGateway.h"
#import "FLBFlutterApplication.h"
#import "FlutterBoostConfig.h"

@implementation NavigationService_flutterCanPop

- (void)onCall:(void (^)(BOOL))result
        canPop:(BOOL)canPop
{
    //Add your handler code here!
    if ([[FLBFlutterApplication sharedApplication].platform respondsToSelector:@selector(flutterCanPop:)]) {
        [[FLBFlutterApplication sharedApplication].platform flutterCanPop:canPop];
    }
}

#pragma mark - Do not edit these method.
- (void)__flutter_p_handler_flutterCanPop:(NSDictionary *)args result:(void (^)(BOOL))result {
    [self onCall:result canPop:[args[@"canPop"] boolValue]];
}
+ (void)load{
    [[ServiceGateway sharedInstance] registerHandler:[NavigationService_flutterCanPop new]];
}
- (NSString *)service
{
    return @"NavigationService";
}
@end
