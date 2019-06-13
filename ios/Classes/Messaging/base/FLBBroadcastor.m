//
//  FLBBroadcastor.m
//  flutter_boost
//
//  Created by Jidong Chen on 2019/6/13.
//

#import "FLBBroadcastor.h"

@interface FLBBroadcastor()
@property (nonatomic,strong) FlutterMethodChannel *channel;
@property (nonatomic,strong) NSMutableDictionary *lists;

@end

@implementation FLBBroadcastor

- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)channel
{
    if (self = [super init]) {
        _channel = channel;
        _lists = NSMutableDictionary.new;
    }
    return self;
}

- (void)sendEvent:(NSString *)eventName
        arguments:(NSDictionary *)arguments
           result:(void (^)(id _Nonnull))result
{
    if(!eventName) return;
    NSMutableDictionary *msg = NSMutableDictionary.new;
    msg[@"name"] = eventName;
    msg[@"arguments"] = arguments;
    [_channel invokeMethod:@"__event__"
                 arguments:msg
                    result:result];
}

- (FLBVoidCallback)addEventListener:(FLBEventListener)listner
                            forName:(NSString *)name
{
    if(!name || !listner) return ^{};
    
    NSMutableArray *list = _lists[name];
    if(!list){
        list = NSMutableArray.new;
        _lists[name] = list;
    }
    [list addObject:listner];
    return ^{
        [list removeObject:listner];
    };
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result
{
    if([call.method isEqual:@"__event__"]){
        NSString *name = call.arguments[@"name"];
        NSDictionary *arguments = call.arguments[@"arguments"];
        if(name){
            NSMutableArray *list = _lists[name];
            if(list){
                for(FLBEventListener l in list){
                    l(name,arguments);
                }
            }
        }
    }
}

@end
