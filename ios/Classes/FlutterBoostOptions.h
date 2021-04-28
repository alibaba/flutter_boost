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


#import <Flutter/Flutter.h>

@class FlutterBoostOptions;

///The FlutterBoostOptions's builder object
@interface FlutterBoostOptionsBuilder : NSObject

@property (nonatomic, strong) NSString* initalRoute;
@property (nonatomic, strong) NSString* dartEntryPoint;
@property (nonatomic, strong) FlutterDartProject* dartObject;

/// builder to set initalRoute
/// @param initalRoute initalRoute you that flutter side will run
- (FlutterBoostOptionsBuilder*)initalRoute: (NSString*)initalRoute;

/// builder to set dartEntryPoint
/// @param dartEntryPoint dartEntryPoint flutter side will run
- (FlutterBoostOptionsBuilder*)dartEntryPoint: (NSString*) dartEntryPoint;

/// builder to set dartObject
/// @param dartObject dartObject that will pass to flutter engine
- (FlutterBoostOptionsBuilder*)dartObject: (FlutterDartProject*)dartObject;

///build a FlutterBoostOptions object using this builder
- (FlutterBoostOptions*)build;

@end


/// initalRoute that flutter will take
@interface FlutterBoostOptions : NSObject

@property (nonatomic, strong) NSString* initalRoute;
@property (nonatomic, strong) NSString* dartEntryPoint;
@property (nonatomic, strong) FlutterDartProject* dartObject;

+ (FlutterBoostOptions*)createDefault;

/// init FlutterBoostOptions with a FlutterBoostOptionsBuilder
/// @param builder FlutterBoostOptionsBuilder instance
- (instancetype)initWithBuilder:(FlutterBoostOptionsBuilder*)builder;


@end


