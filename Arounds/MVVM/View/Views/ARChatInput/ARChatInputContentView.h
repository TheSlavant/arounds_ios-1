//
//  ARChatInputContentView.h
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/5/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesToolbarContentView.h>

@class JSQMessagesViewController;
@interface ARChatInputContentView : JSQMessagesToolbarContentView

@property (weak, nonatomic) IBOutlet UIView *topContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerHeightConstraint;

@property (weak, nonatomic) JSQMessagesViewController *messagesViewController;

@end
