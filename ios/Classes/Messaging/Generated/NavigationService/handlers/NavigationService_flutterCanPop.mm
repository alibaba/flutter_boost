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
#import "NavigationService_flutterCanPop.h"
#import <xservice_kit/ServiceGateway.h>
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
