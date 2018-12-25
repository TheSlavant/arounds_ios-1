//
//  ARChatInputContentView.m
//  Arounds
//
//  Created by Samvel Pahlevanyan on 6/5/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

#import "ARChatInputContentView.h"
#import "JSQMessagesInputToolbar.h"
#import "JSQMessagesViewController.h"
#import <objc/runtime.h>

@implementation JSQMessagesInputToolbar (ARInputCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(loadToolbarContentView);
        SEL swizzledSelector = @selector(ar_loadToolbarContentView);
        
        Method originalMethod = class_getInstanceMethod([self class], originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (JSQMessagesToolbarContentView *)ar_loadToolbarContentView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ARChatInputContentView"
                                                             owner:self
                                                           options:nil];
    return topLevelObjects.firstObject;
}

@end

static void * kARMessagesKeyValueObservingContext = &kARMessagesKeyValueObservingContext;

@interface ARChatInputContentView()

@end

@implementation ARChatInputContentView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self addObserver:self
           forKeyPath:@"topContainerView.layer.bounds"
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
              context:kARMessagesKeyValueObservingContext];
    
    //    [self loadDummyView];
}

- (void)dealloc {
    [self removeObserver:self
              forKeyPath:@"topContainerView.layer.bounds"
                 context:kARMessagesKeyValueObservingContext];
}

- (void)loadDummyView {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topContainerView addSubview:view];
    NSLayoutConstraint *contentHeightConstraint = [view.heightAnchor constraintEqualToConstant:0];
    contentHeightConstraint.active = YES;
    
    [view.topAnchor constraintEqualToAnchor:self.topContainerView.topAnchor].active = YES;
    [view.leftAnchor constraintEqualToAnchor:self.topContainerView.leftAnchor].active = YES;
    [view.bottomAnchor constraintEqualToAnchor:self.topContainerView.bottomAnchor].active = YES;
    [view.rightAnchor constraintEqualToAnchor:self.topContainerView.rightAnchor].active = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        contentHeightConstraint.constant = 30;
        [self setNeedsLayout];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    
    if (context == kARMessagesKeyValueObservingContext) {
        if (object == self && [keyPath isEqualToString:@"topContainerView.layer.bounds"]) {
            CGFloat oldHeight = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue].size.height;
            CGFloat newHeight = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue].size.height;
            
            CGFloat dy = newHeight - oldHeight;
            [self updateToolbarHeightByDelta:dy];
        }
    }
}

- (void)updateToolbarHeightByDelta:(CGFloat)delta {
    [self updateToolbarHeight:delta];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.messagesViewController performSelector:NSSelectorFromString(@"jsq_updateCollectionViewInsets")];
#pragma clang diagnostic pop
    
    if (self.messagesViewController.automaticallyScrollsToMostRecentMessage) {
        [self.messagesViewController scrollToBottomAnimated:NO];
    }
    
    [self.textView setContentSize:self.textView.contentSize];
}

- (void)updateToolbarHeight:(CGFloat) height {
    if (!self.messagesViewController) {
        return;
    }
    
    SEL sel = NSSelectorFromString(@"jsq_adjustInputToolbarHeightConstraintByDelta:");
    
    NSMethodSignature *signature = [[self.messagesViewController class] instanceMethodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = sel;
    // note that the first argument has index 2!
    [invocation setArgument:&height atIndex:2];
    
    // with delay
    [invocation performSelector:@selector(invokeWithTarget:) withObject:self.messagesViewController afterDelay:0];
}

@end
