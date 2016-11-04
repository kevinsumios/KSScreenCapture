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
- (void)KSScreenCaptureDidFinish:(KSScreenCapture *)capture path:(NSString *)videoPath;

@end

@interface KSScreenCapture : NSObject
@property id<KSScreenCaptureDelegate> delegate;
@property KSAudioCapture *audioCapture;
// With audio record or not
@property BOOL muted;
// Permission alert description.
@property  NSString * _Nullable phPermissionAlertTitle;
@property NSString * _Nullable phPermissionAlertMessage;
@property  NSString * _Nullable phPermissionAlertOK;
@property NSString * _Nullable phPermissionAlertSetting;

- (id)initWithTarget:(__kindof UIViewController *)target CaptureLayer:(CALayer *)layer;
- (void)setCaptureLayer:(CALayer *)layer;
- (void)setFrameRate:(NSUInteger)rate;
- (void)startRecordSuccess:(void (^)(void))success fail:(void (^)(void))fail;
- (void)stopRecord;
// A simple function to save the video in the phots album
// with permission checking. If you need to do complicate
// file operation, it is recommand to do it yourself.
- (void)saveVideoAtPathToSavedPhotosAlbum:(NSString *)path completeSeletor:(SEL)action;

@end
