//
//  ViewController.m
//  KSScreenCaptureDemo
//
//  Created by Kevin Sum on 04/11/2016.
//  Copyright © 2016 kevinsumios. All rights reserved.
//

#import "ViewController.h"
#import "ACEDrawingView.h"
#import "KSScreenCapture.h"

@interface ViewController () <ACEDrawingViewDelegate, KSScreenCaptureDelegate>

@end

@implementation ViewController {
    IBOutlet ACEDrawingView *drawingView;
    // Make sure your record view frame size is times of 32!
    IBOutlet UIView *recordView;
    KSScreenCapture *_capture;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    drawingView.delegate = self;
    
    // Initialize the screen capture
    _capture = [[KSScreenCapture alloc] initWithTarget:self CaptureLayer:recordView.layer];
    _capture.highlighted = NO;
    _capture.delegate = self;
}

- (IBAction)onRecordClick:(UIButton *)sender {
    if (sender.tag == 0) {
        // Record drawing view
        [_capture startRecordSuccess:^{
            sender.tag = 1;
            [sender setTitle:@"Stop" forState:UIControlStateNormal];
        } fail:^{
            NSLog(@"Start record failed!");
        }];
        
    } else if (sender.tag == 1) {
        // Stop drawing view and pop up save alert
        sender.tag = 0;
        [sender setTitle:@"Record" forState:UIControlStateNormal];
        [drawingView clear];
        [_capture stopRecord];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KSScreenCaptureDelegate methods

- (void)KSScreenCaptureDidFinish:(KSScreenCapture *)capture path:(NSString *)videoPath {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Save to photo album?" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [capture saveVideoAtPathToSavedPhotosAlbum:videoPath completeSeletor:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
