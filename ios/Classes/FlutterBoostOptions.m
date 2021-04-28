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

#import "FlutterBoostOptions.h"


@implementation FlutterBoostOptionsBuilder

- (instancetype)init
{
    self = [super init];
    if (self) {
        //set default value
        self.initalRoute = @"/";
        self.dartEntryPoint = @"main";
    }
    return self;
}

- (FlutterBoostOptionsBuilder*)initalRoute: (NSString*)initalRoute{
    self.initalRoute = initalRoute;
    return self;
}


- (FlutterBoostOptionsBuilder*)dartEntryPoint: (NSString*) dartEntryPoint{
    self.dartEntryPoint = dartEntryPoint;
    return self;
}


- (FlutterBoostOptionsBuilder*)dartObject: (FlutterDartProject*)dartObject{
    self.dartObject = dartObject;
    return self;
}

- (FlutterBoostOptions*)build{
    return [[FlutterBoostOptions alloc]initWithBuilder:self];
}
@end




@implementation FlutterBoostOptions

+ (FlutterBoostOptions*)createDefault{
    return [[[FlutterBoostOptionsBuilder alloc]init]build];
}
\
- (instancetype)initWithBuilder:(FlutterBoostOptionsBuilder*)builder
{
    self = [super init];
    if (self) {
        //set value from builder.
        self.initalRoute = builder.initalRoute;
        self.dartEntryPoint = builder.dartEntryPoint;
        self.dartObject = builder.dartObject;
    }
    return self;
}

@end



