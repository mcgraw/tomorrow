//
//  BatchNativeAd.h
//  batch
//
//  https://batch.com
//  Copyright (c) 2015 Batch SDK. All rights reserved.
//

#import <Foundation/Foundation.h>


/// Enum of the different BatchNativeAd states
typedef NS_ENUM(NSInteger, BatchNativeAdState)
{
    BatchNativeAdStateNotLoaded = 0,
    
    BatchNativeAdStateLoading = 1,
    
    BatchNativeAdStateLoadFailed = 2,
    
    BatchNativeAdStateReady = 3,
    
    BatchNativeAdStateExpired = 4
};


typedef NS_OPTIONS(NSUInteger, BatchNativeAdContent)
{
    BatchNativeAdContentNone        = 0,
    BatchNativeAdContentCreative    = 1 << 0,
};


@interface BatchNativeAd : NSObject

@property (readonly) BatchNativeAdState state;

@property (readonly) NSString *placement;

@property (readonly) NSString *title;

@property (readonly) NSString *subtitle;

@property (readonly) NSString *callToAction;

@property (readonly) UIImage *icon;

@property (readonly) UIImage *creative;

/*!
 @method init
 @warning Never call this method.
 */
- (instancetype)init NS_UNAVAILABLE;

/*!
 @method load
 @warning Never call this method.
 */
+ (void)load NS_UNAVAILABLE;

- (instancetype)initWithPlacement:(NSString *)placement andContent:(BatchNativeAdContent)content __attribute__((nonnull, warn_unused_result)) NS_AVAILABLE_IOS(6_0);

- (void)registerView:(UIView *)view __attribute__((nonnull)) NS_AVAILABLE_IOS(6_0);

- (void)unregisterView;

- (void)performClickAction;

@end