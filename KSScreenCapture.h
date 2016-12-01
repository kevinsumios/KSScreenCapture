//
//  KSScreenCapture.h
//  ScreenRecorderDemo
//
//  Created by Kevin Sum on 31/10/2016.
//  Copyright © 2016 vContent. All rights reserved.
//

#import "THCapture.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "KSAudioCapture.h"

#ifndef ddLogLevel
#define ddLogLevel DDLogLevelInfo
#endif

@class KSScreenCapture;

@protocol KSScreenCaptureDelegate <NSObject>
- (void)KSScreenCaptureDidFinish:(KSScreenCapture * _Nonnull)capture path:(NSString * _Nonnull)videoPath thumb:(UIImage *)thumb;

@end

@interface KSScreenCapture : NSObject
@property _Nullable id<KSScreenCaptureDelegate> delegate;
@property  KSAudioCapture * _Nullable audioCapture;
// With audio record or not
@property BOOL muted;
// Highlight the record view or not
@property BOOL highlighted;
// Permission alert description.
@property  NSString * _Nullable phPermissionAlertTitle;
@property NSString * _Nullable phPermissionAlertMessage;
@property  NSString * _Nullable phPermissionAlertOK;
@property NSString * _Nullable phPermissionAlertSetting;

- (id _Nonnull)initWithTarget:(__kindof UIViewController * _Nonnull)target CaptureLayer:(CALayer * _Nonnull)layer;
- (void)setCaptureLayer:(CALayer * _Nonnull)layer;
- (void)setFrameRate:(NSUInteger)rate;
- (void)startRecordSuccess:(void (^ _Nullable)(void))success fail:(void (^ _Nullable)(void))fail;
- (void)stopRecord;
// A simple function to save the video in the phots album
// with permission checking. If you need to do complicate
// file operation, it is recommand to do it yourself.
- (void)saveVideoAtPathToSavedPhotosAlbum:(NSString * _Nonnull)path completeSeletor:(SEL _Nullable)action;

@end
