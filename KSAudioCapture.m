//
//  KSAudioCapture.m
//  ScreenRecorderDemo
//
//  Created by Kevin Sum on 31/10/2016.
//  Copyright © 2016 vContent. All rights reserved.
//

#import "KSAudioCapture.h"
#import "KSScreenCapture.h"
#import <AVFoundation/AVFoundation.h>

#define defaultFileName @"ksaudiotmp"

@interface KSAudioCapture () <AVAudioRecorderDelegate>

@end

@implementation KSAudioCapture {
    AVAudioRecorder *_recorder;
    AVAudioSession *_session;
    NSURL *_fileURL;
    NSString *_fileName;
    NSDictionary *_setting;
    __weak __kindof UIViewController *_target;
}

#pragma mark - Initialize methods

- (id)initWithURL:(NSURL *)url target:(__kindof UIViewController *)target setting:(NSDictionary *)setting {
    if (url) {
        _fileURL = url;
    } else {
        _fileURL = [KSAudioCapture defaultURL];
    }
    if (setting) {
        _setting = setting;
    } else {
        _setting = [KSAudioCapture defaultSetting];
    }
    return [self initRecorderWithTarget:target];
}

- (id)initWithFileName:(NSString *)fileName target:(__kindof UIViewController *)target setting:(NSDictionary *)setting {
    if (fileName) {
        _fileURL = [KSAudioCapture URLWithFileName:fileName];
    } else {
        _fileURL = [KSAudioCapture defaultURL];
    }
    if (setting) {
        _setting = setting;
    } else {
        _setting = [KSAudioCapture defaultSetting];
    }
    return [self initRecorderWithTarget:target];
}

- (id)initRecorderWithTarget:(__kindof UIViewController *)target {
    if (!self) {
        self = [super init];
    }
    _target = target;
    return self;
}

+ (NSURL *)defaultURL {
    return [KSAudioCapture URLWithFileName:defaultFileName];
}

+ (NSURL *)URLWithFileName:(NSString *)fileName {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [[docDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:@"m4a"];
    return [NSURL URLWithString:filePath];
}

+ (NSDictionary *)defaultSetting {
    return @{
             AVSampleRateKey: [NSNumber numberWithFloat: 44100.0],// Sample rate
             AVNumberOfChannelsKey: [NSNumber numberWithInteger:1],// Channel number
             AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatMPEG4AAC]// Format
             };
}

#pragma mark - Action methods

- (void)startRecordSuccess:(void  (^)(void))success fail:(void (^)(void))fail {
    // Check the permittion granting status.
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
        if (granted) {
            // Initialize the audio recorder.
            if (!_recorder) {
                // Setup session
                _session = [AVAudioSession sharedInstance];
                [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
                NSError *error;
                _recorder = [[AVAudioRecorder alloc] initWithURL:_fileURL settings:_setting error:&error];
                if (error) {
                    DDLogError(@"Audio recorder initialize failed: %@", error);
                    _recorder = nil;
                    if (fail) {
                        fail();
                        return;
                    }
                }
                _recorder.meteringEnabled = YES;
                _recorder.delegate = self;
                [_recorder prepareToRecord];
            }
            // Start recordding.
            if ([_session setActive:YES error:nil] && [_recorder record] && success) {
                success();
            } else if (fail) {
                fail();
            }
        }
        else {
            _avPermissionAlertTitle = _avPermissionAlertTitle?:NSLocalizedString(@"Warning!", nil);
            _avPermissionAlertMessage = _avPermissionAlertMessage?:NSLocalizedString(@"Please grant the audio permission.", nil);
            _avPermissionAlertOK = _avPermissionAlertOK?:NSLocalizedString(@"OK", nil);
            _avPermissionAlertSetting = _avPermissionAlertSetting?:NSLocalizedString(@"Setting", nil);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:_avPermissionAlertTitle message:_avPermissionAlertMessage preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:_avPermissionAlertSetting style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:settingURL]) {
                    [[UIApplication sharedApplication] openURL:settingURL];
                }
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:_avPermissionAlertOK style:UIAlertActionStyleCancel handler:nil]];
            _recorder = nil;
            if (fail) {
                fail();
            }
            [_target presentViewController:alert animated:YES completion:nil];
        }
        });
    }];
}

- (void)pauseRecord {
    if (_recorder.isRecording) {
        [_recorder pause];
    }
}

- (void)stopRecord {
    [_recorder stop];
    [_session setActive:NO error:nil];
}

- (BOOL)isRecording {
    return _recorder.isRecording;
}

#pragma mark - AVAudioRecorderDelegate methods

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (_delegate && [_delegate respondsToSelector:@selector(KSAudioCaptureDidFinishWithURL:successfully:)]) {
        [_delegate KSAudioCaptureDidFinishWithURL:_fileURL successfully:flag];
    }
}

@end
