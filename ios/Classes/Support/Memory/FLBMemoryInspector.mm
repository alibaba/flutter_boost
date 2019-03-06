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

#import "FLBMemoryInspector.h"

#include <mach/mach.h>
#include <stdlib.h>
#include <sys/sysctl.h>

#define MB(_v_) (_v_*1024*1024)
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface FLBMemoryInspector()
@property(nonatomic,assign) FLBMemoryCondition condition;
@end

@implementation FLBMemoryInspector

+ (instancetype)sharedInstance
{
    static id sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[self.class alloc] init];
    });
    
    return sInstance;
}

static bool isHighterThanIos9(){
    bool ret = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0.0");
    return ret;
}

static int64_t memoryFootprint()
{
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (result != KERN_SUCCESS)
        return -1;
    return vmInfo.phys_footprint;
}


static int64_t _memoryWarningLimit()
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine =(char *) malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);

    if ([platform isEqualToString:@"iPhone5,1"])    return MB(600);
    if ([platform isEqualToString:@"iPhone5,2"])    return MB(600);
    if ([platform isEqualToString:@"iPhone5,3"])    return MB(600);
    if ([platform isEqualToString:@"iPhone5,4"])    return MB(600);
    if ([platform isEqualToString:@"iPhone6,1"])    return MB(600);
    if ([platform isEqualToString:@"iPhone6,2"])    return MB(600);
    if ([platform isEqualToString:@"iPhone7,1"])    return MB(600);
    if ([platform isEqualToString:@"iPhone7,2"])    return MB(600);
    if ([platform isEqualToString:@"iPhone8,1"])    return MB(1280);
    if ([platform isEqualToString:@"iPhone8,2"])    return MB(1280);
    if ([platform isEqualToString:@"iPhone8,4"])    return MB(1280);
    if ([platform isEqualToString:@"iPhone9,1"])    return MB(1280);
    if ([platform isEqualToString:@"iPhone9,2"])    return MB(1950);
    if ([platform isEqualToString:@"iPhone9,3"])    return MB(1280);
    if ([platform isEqualToString:@"iPhone9,4"])    return MB(1950);
    if ([platform isEqualToString:@"iPhone10,1"])   return MB(1280);
    if ([platform isEqualToString:@"iPhone10,2"])   return MB(1950);
    if ([platform isEqualToString:@"iPhone10,3"])   return MB(1950);
    if ([platform isEqualToString:@"iPhone10,4"])   return MB(1280);
    if ([platform isEqualToString:@"iPhone10,5"])   return MB(1950);
    if ([platform isEqualToString:@"iPhone10,6"])   return MB(1950);
    
    return 0;
}

static int64_t getLimit(){
    const static size_t l = _memoryWarningLimit();
    return l;
}

- (int64_t)deviceMemory
{
    int64_t size = [NSProcessInfo processInfo].physicalMemory;
    return size;
}

- (BOOL)smallMemoryDevice
{
    if([self deviceMemory] <= MB(1024)){
        return YES;
    }else{
        return NO;
    }
}

- (FLBMemoryCondition)currentCondition
{
    FLBMemoryCondition newCondition = FLBMemoryConditionUnknown;
    

    if(!isHighterThanIos9() || getLimit() <= 0){
        newCondition = FLBMemoryConditionUnknown;
    }else if(memoryFootprint() < getLimit() * 0.40){
        newCondition = FLBMemoryConditionNormal;
    }else if(memoryFootprint() < getLimit() * 0.60){
        newCondition = FLBMemoryConditionLowMemory;
    }else if(memoryFootprint() < getLimit() * 0.80){
        newCondition = FLBMemoryConditionExtremelyLow;
    }else{
        newCondition = FLBMemoryConditionAboutToDie;
    }
    
    if (newCondition != self.condition) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFLBMemoryInspectorChangedNotification
                                                            object:@{kFLBMemoryInspectorKeyCondition:@(newCondition)}];
    }
    
    self.condition = newCondition;
    
    return newCondition;
}

- (int64_t)currentFootPrint
{
    return memoryFootprint();
}

@end
