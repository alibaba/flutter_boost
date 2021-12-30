#import <Flutter/Flutter.h>

@interface FLNativeViewFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype _Nonnull)initWithMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger;
@end

@interface FLNativeView : NSObject <FlutterPlatformView>

- (instancetype _Nonnull)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>* _Nonnull)messenger;

- (UIView* _Nonnull)view;
@end
