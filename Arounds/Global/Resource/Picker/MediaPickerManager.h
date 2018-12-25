//
//  MediaPickerManager.h
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/30/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MediaTypeImage = 1 << 0,
    MediaTypeVideo = 1 << 1,
    MediaTypeImageVideo = 2 << 2,
} MediaType;

@class UIToolbar;
@class UIViewController;
@interface MediaPickerManager : NSObject

+ (instancetype)sharedManager;

@property (strong, nonatomic) UIViewController *fromVC;

- (void)pickPhotoOrVideoWithCompletion:(void(^)(MediaType type, NSData *data, NSURL *mediaUrl))handler;

- (void)pickMediaWithType:(MediaType)mediaType
               completion:(void(^)(MediaType type, NSData *data, NSURL *mediaUrl))handler;

- (void)openTakePhotoWithCompletion:(void(^)(NSData *data))handler;
- (void)openCemaraRollWithCompletion:(void(^)(NSData *data))handler;
- (void)openCemaraRoll:(BOOL)allowEditing completion:(void(^)(NSData *data))handler;

@end
