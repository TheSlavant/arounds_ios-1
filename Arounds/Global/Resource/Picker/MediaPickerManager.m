//
//  MediaPickerManager.m
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/30/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

#import "MediaPickerManager.h"
#import <UIKit/UIKit.h>
#import "UIImage+FixOrientation_h.h"

@import MobileCoreServices;

@interface MediaPickerManager() <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>

@property (nonatomic) MediaType mediaType;

@property (copy, nonatomic) void (^callback) (MediaType type, NSData *data, NSURL *mediaUrl);\
@property (copy, nonatomic) void (^openCallback) (NSData *data);
@property (strong,nonatomic) UIAlertController *actionSheetController;

@end

@implementation MediaPickerManager

+ (instancetype)sharedManager
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void)pickPhotoOrVideoWithCompletion:(void (^)(MediaType, NSData *, NSURL *))handler
{
    [self pickMediaWithType:(MediaTypeImage | MediaTypeVideo) completion:handler];
}

- (void)pickMediaWithType:(MediaType)mediaType completion:(void (^)(MediaType, NSData *, NSURL *))handler
{
    self.mediaType = mediaType;
    
    self.callback = handler;
    
    NSString *takeButtonTitle = @"";;
    if ((mediaType & MediaTypeImage) && (mediaType & MediaTypeVideo)) {
        takeButtonTitle = NSLocalizedString(@"Take Photo or Video", nil);
    } else if (mediaType & MediaTypeImage) {
        takeButtonTitle = NSLocalizedString(@"Take Photo", nil);
    } else if (mediaType & MediaTypeVideo) {
        takeButtonTitle = NSLocalizedString(@"Take Video", nil);
    } else if (mediaType & MediaTypeVideo) {
        takeButtonTitle = NSLocalizedString(@"Upload Photo", nil);
    }
    
    self.actionSheetController = [UIAlertController alertControllerWithTitle:nil
                                                                     message:nil
                                                              preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action)
                                   {
                                       [self.actionSheetController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    UIAlertAction *cameraRollAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open Camera Roll", nil)
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action)
                                       {
                                           [self openCameraRoll:YES];
                                       }];
    [self.actionSheetController addAction:cameraRollAction];
    UIAlertAction *takeAction = [UIAlertAction actionWithTitle:takeButtonTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action)
                                 {
                                     [self openCamera];
                                 }];
    
    [self.actionSheetController addAction:takeAction];
    [self.actionSheetController addAction:cancelAction];
    
    UIViewController *vc = [self topViewController];
    [vc presentViewController:self.actionSheetController animated:YES completion:nil];
}

- (void)openTakePhotoWithCompletion:(void (^)(NSData *))handler {
    self.openCallback = handler;
    self.mediaType = MediaTypeImage;
    [self openCamera];
}

- (void)openCemaraRoll:(BOOL)allowEditing completion:(void (^)(NSData *))handler {
    self.openCallback = handler;
    self.mediaType = MediaTypeImage;
    [self openCameraRoll:allowEditing];
}

- (void)openCemaraRollWithCompletion:(void (^)(NSData *))handler {
    [self openCemaraRoll:YES completion:handler];
}

- (void)openCameraRoll:(BOOL)allowEditing
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = allowEditing;
        
        NSArray *mediaTypes;
        if ((self.mediaType & MediaTypeImage) && (self.mediaType & MediaTypeVideo)) {
            mediaTypes = @[(__bridge NSString *) kUTTypeMovie, (__bridge NSString *) kUTTypeImage];
        } else if (self.mediaType & MediaTypeImage) {
            mediaTypes = @[(__bridge NSString *) kUTTypeImage];
        } else if (self.mediaType & MediaTypeVideo) {
            mediaTypes = @[(__bridge NSString *) kUTTypeMovie];
        }
        
        
        imagePicker.mediaTypes = mediaTypes;
        UIViewController *vc = self.fromVC ?: [self topViewController];
        [vc presentViewController:imagePicker animated:YES completion:nil];
    } else {
        [self showAlertWithTitle:@"Error" message:NSLocalizedString(@"Camera not available", nil)];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        BOOL isMovie = UTTypeConformsTo((__bridge CFStringRef)mediaType, kUTTypeMovie) != 0;
        if (isMovie) {
            NSURL *url = info[UIImagePickerControllerMediaURL];
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (self.callback) {
                self.callback (MediaTypeVideo, data, url);
            }
        } else {
            UIImage *image = info[UIImagePickerControllerEditedImage];
            if (!image) {
                image = info[UIImagePickerControllerOriginalImage];
            }
            UIImage * selectPhoto = [image fixOrientation];
            NSData *data = UIImageJPEGRepresentation(selectPhoto, 1);
            if (self.openCallback) {
                self.openCallback(data);
            } else if (self.callback) {
                self.callback (MediaTypeImage, data, nil);
            }
        }
        self.callback = nil;
    }];
}

- (void)openCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if([UIImagePickerController availableCaptureModesForCameraDevice:
            UIImagePickerControllerCameraDeviceRear]) {
            
            UIImagePickerController *cameraPicker = [[UIImagePickerController alloc] init];
            cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraPicker.allowsEditing = YES;
            
            NSArray *mediaTypes;
            if ((self.mediaType & MediaTypeImage) && (self.mediaType & MediaTypeVideo)) {
                mediaTypes = @[(__bridge NSString *) kUTTypeMovie, (__bridge NSString *) kUTTypeImage];
            } else if (self.mediaType & MediaTypeImage) {
                mediaTypes = @[(__bridge NSString *) kUTTypeImage];
            } else if (self.mediaType & MediaTypeVideo) {
                mediaTypes = @[(__bridge NSString *) kUTTypeMovie];
            }
            
            cameraPicker.mediaTypes = mediaTypes;
            cameraPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            
            cameraPicker.delegate = self;
            UIViewController *vc = self.fromVC ?: [self topViewController];
            [vc presentViewController:cameraPicker animated:YES completion:nil];
        }
    } else {
        [self showAlertWithTitle:@"Error" message:NSLocalizedString(@"Camera not available", nil)];
    }
    
}

- (UIViewController *)topViewController
{
    UIViewController *vc = [[UIApplication sharedApplication].delegate window].rootViewController;
    return [self topViewControllerWithRootViewController:vc];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    [alert addAction:okAction];
    
    [[self topViewController] presentViewController:alert animated:YES completion:nil];
}

@end
