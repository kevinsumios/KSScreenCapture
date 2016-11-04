//
//  KSScreenCapture.m
//  ScreenRecorderDemo
//
//  Created by Kevin Sum on 31/10/2016.
//  Copyright © 2016 vContent. All rights reserved.
//

#import "KSScreenCapture.h"
#import "KSAudioCapture.h"
#import <Photos/PHPhotoLibrary.h>

@interface KSScreenCapture () <THCaptureDelegate, KSAudioCaptureDelegate>

@end

@implementation KSScreenCapture {
    THCapture *_capture;
//    KSAudioCapture *_audioCapture;
    NSString *_videoPath;
    NSString *_audioPath;
    __kindof UIViewController *_target;
}

#pragma mark - Initialize methods

- (id)initWithTarget:(__kindof UIViewController *)target {
    if (!self) {
        self = [super init];
    }
    _target = target;
    if (!_capture) {
        _capture = [[THCapture alloc] init];
        _capture.delegate = self;
    }
    _muted = NO;
    return self;
}

- (id)initWithTarget:(__kindof UIViewController *)target CaptureLayer:(CALayer *)layer {
    self = [self initWithTarget:target];
    _capture.captureLayer = layer;
    return self;
}

- (void)configAudioCapture {
    _audioCapture = [[KSAudioCapture alloc] initWithFileName:nil target:_target setting:nil];
    _audioCapture.delegate = self;
}

#pragma mark - Global config methods

- (void)setCaptureLayer:(CALayer *)layer {
    _capture.captureLayer = layer;
}

- (void)setFrameRate:(NSUInteger)rate {
    _capture.frameRate = rate;
}

#pragma mark - Capture methods

- (void)startRecordSuccess:(void (^)(void))success fail:(void (^)(void))fail {
    // Initialize the audio capture.
    if (!_muted && !_audioCapture) {
        [self configAudioCapture];
    } else if (_muted) {
        _audioCapture = nil;
    }
    // Start capture with audio recorder or directly if muted.
    void (^recordBlock)(void) = ^{
        if ([_capture startRecording1] && success) {
            success();
        } else if (fail) {
            fail();
        }
    };
    if (_audioCapture) {
        [_audioCapture startRecordSuccessfully:^{
            recordBlock();
        } failed:^{
            DDLogError(@"Start audio record error.");
            if (fail) {
                fail();
            }
        }];
    } else {
        recordBlock();
    }
}

- (void)stopRecord {
    [_capture stopRecording];
    if (_audioCapture) {
        [_audioCapture stopRecord];
    }
}

#pragma mark - File methods

- (void)mergeVideo:(NSString *)videoPath audio:(NSString *)audioPath {
    if (videoPath) {
        _videoPath = videoPath;
    }
    if (audioPath) {
        _audioPath = audioPath;
    }
    if (_videoPath && _audioPath) {
        [THCaptureUtilities mergeVideo:_videoPath andAudio:_audioPath andTarget:self andAction:@selector(mergeDidFinish:WithError:)];
    }
}

- (void)mergeDidFinish:(NSString *)outputPath WithError:(NSError *)error {
    DDLogInfo(@"Merge finished: %@.", outputPath);
    [self exportVideo:outputPath];
}

- (void)exportVideo:(NSString *)path {
    if ([_delegate respondsToSelector:@selector(KSScreenCaptureDidFinish:path:)]) {
        [_delegate KSScreenCaptureDidFinish:self path:path];
    }
}

- (void)saveVideoAtPathToSavedPhotosAlbum:(NSString *)path completeSeletor:(SEL)action {
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                switch (status) {
                    case PHAuthorizationStatusAuthorized:
                        UISaveVideoAtPathToSavedPhotosAlbum(path, _target, action, nil);
                        break;
                    case PHAuthorizationStatusDenied:
                        [self savePhotosAlbumAlert];
                        break;
                    default:
                        DDLogInfo(@"Save video fail since not determine authorization status.");
                        break;
                }
            }];
        });
    }
}

- (void)savePhotosAlbumAlert {
    _phPermissionAlertTitle = _phPermissionAlertTitle?:NSLocalizedString(@"Warning!", nil);
    _phPermissionAlertMessage = _phPermissionAlertMessage?:NSLocalizedString(@"Please grant the photo album permission.", nil);
    _phPermissionAlertOK = _phPermissionAlertOK?:NSLocalizedString(@"OK", nil);
    _phPermissionAlertSetting = _phPermissionAlertSetting?:NSLocalizedString(@"Setting", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_phPermissionAlertTitle message:_phPermissionAlertMessage preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:_phPermissionAlertSetting style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:settingURL]) {
            [[UIApplication sharedApplication] openURL:settingURL];
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:_phPermissionAlertOK style:UIAlertActionStyleCancel handler:nil]];
    [_target presentViewController:alert animated:YES completion:nil];
}

#pragma mark - THCaptureDelegate methods

- (void)recordingFinished:(NSString *)outputPath {
    DDLogInfo(@"Record finished: %@.", outputPath);
    if (!_audioCapture) {
        // If there is no audio capture, export the video path directly
        [self exportVideo:outputPath];
    }
    else {
        [self mergeVideo:outputPath audio:nil];
    }
}

- (void)recordingFaild:(NSError *)error {
    DDLogError(@"Record failed: %@", error);
}

#pragma mark - KSAudioCaptureDelegate methods

- (void)KSAudioCaptureDidFinishWithURL:(NSURL *)url successfully:(BOOL)flag {
    DDLogInfo(@"Audio record finished: %@.", url);
    [self mergeVideo:nil audio:[url absoluteString]];
}

@end
