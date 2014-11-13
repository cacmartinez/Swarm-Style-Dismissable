//
//  SwarmStyleDismissableView.m
//  SwarmLikeDismissable

//  Copyright 2014 Carlos Compean

//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  Created by Carlos Compean on 12/11/14.
//

#import "SwarmStyleDismissableView.h"

#define DEFAULT_RADIUS 25

@interface SwarmStyleDismissableView()

@property CGPoint oldPosition;
@property UIDynamicAnimator *animator;
@property (weak) UIDynamicItemBehavior *itemBehavior;
@property (weak) UIAttachmentBehavior *attachment;
@property (weak) UIGravityBehavior *gravityBehavior;
//@property CGRect nonDismissingFrame;

@end

@implementation SwarmStyleDismissableView

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialSetup];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialSetup];
    }
    return self;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initialSetup];
    }
    return  self;
}

-(void)initialSetup{
    UIPanGestureRecognizer *panGesture =  [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragging:)];
    _dismissable = YES;
    [self addGestureRecognizer:panGesture];
}

- (void)dragging:(UIPanGestureRecognizer *)sender{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self draggingStarted:sender];
            break;
        case UIGestureRecognizerStateChanged:
            [self draggingMoved:sender];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self draggingEnded:sender];
            break;
        default:
            break;
    }
}

- (void)draggingStarted:(UIPanGestureRecognizer *)gesture{
    
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(swarmDismissableViewManualTraslationDidStart)]) {
        [self.delegate swarmDismissableViewManualTraslationDidStart];
    }
    
    if (self.locationReferenceView) {
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.locationReferenceView];
    } else {
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    }
    
    //if (self.nonDismissingArea) {
//        CGSize size = [self.nonDismissingArea CGSizeValue];
//        self.nonDismissingFrame = CGRectMake(self.animator.referenceView.center.x - size.width/2.0, self.animator.referenceView.center.y - size.height/2.0, size.width, size.height);
//    } else {
//        self.nonDismissingFrame = CGRectMake(self.animator.referenceView.center.x - 50, self.animator.referenceView.center.y - 50, 100, 100);
//    }
    
//    CGRect nonDismissingFrame = CGRectMake(self.animator.referenceView.center.x - 50, self.animator.referenceView.center.y - 50, 100, 100);
//    UIView *nondismissingView = [[UIView alloc] initWithFrame:nonDismissingFrame];
//    nondismissingView.layer.cornerRadius = nonDismissingFrame.size.width / 2.0;
//    nondismissingView.clipsToBounds = YES;
//    nondismissingView.backgroundColor = [UIColor redColor];
//    [self.animator.referenceView addSubview:nondismissingView];
//    CGPoint centerGestureView = [self.animator.referenceView convertPoint:gesture.view.center toView:nondismissingView];
//    UIView *pixelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//    pixelView.center = centerGestureView;
//    pixelView.backgroundColor = [UIColor greenColor];
//    [nondismissingView addSubview:pixelView];
    //[self.animator.referenceView insertSubview:nondismissingView belowSubview:gesture.view];
    
    self.oldPosition = [gesture locationInView:self.animator.referenceView];
    //    if (!self.gravity) {
    //        //self.gravity = [[UIGravityBehavior alloc] initWithItems:@[self.dynamicView]];
    //        //self.gravity.magnitude = 0.5;
    //        //[self.animator addBehavior:self.gravity];
    //    }
    
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[gesture.view]];
    self.itemBehavior = itemBehavior;
    itemBehavior.angularResistance = CGFLOAT_MAX;
    [self.animator addBehavior:itemBehavior];
    
    //UIGravityBehavior *gravity2 = [[UIGravityBehavior alloc] initWithItems:@[self.dynamicView]];
    //[gravity2 setAngle:3*M_PI_2];
    //[self.animator addBehavior:gravity2];
    CGPoint locationInView = [gesture locationInView:self.animator.referenceView];
    UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:gesture.view offsetFromCenter:UIOffsetMake(locationInView.x - gesture.view.center.x, locationInView.y - gesture.view.center.y) attachedToAnchor:[gesture locationInView:self.animator.referenceView]];
    self.attachment = attachment;
    //    self.attachment = [[UIAttachmentBehavior alloc] initWithItem:gesture.view attachedToAnchor:CGPointZero];
    [self.animator addBehavior:attachment];
}

- (CGFloat)percentageDismissableWithDissmissableRadius:(CGFloat)radius centerReference:(CGPoint)centerReference currentViewCenter:(CGPoint)viewCenter{
    CGFloat viewDistanceFromCenter = sqrt(pow(viewCenter.x - centerReference.x, 2.0)+pow(viewCenter.y - centerReference.y, 2.0));
    //CGFloat nonDismissingFrameDistanceFromCenter = sqrt(pow(nonDismissingFrameOrigin.x - centerReferenceView.x, 2.0)+pow(nonDismissingFrameOrigin.y - centerReferenceView.y, 2.0));
    CGFloat percentage = (viewDistanceFromCenter/radius > 1)? 1 : viewDistanceFromCenter/radius;
    return percentage;
}

- (void)draggingMoved:(UIPanGestureRecognizer *)gesture{
//    UIView *nondismissingView = self.animator.referenceView.subviews.lastObject;
//    UIView *pixelView = nondismissingView.subviews.firstObject;
//    pixelView.center = [self.animator.referenceView convertPoint:gesture.view.center toView:nondismissingView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(swarmDismissableViewManualTraslationDidMoveWithPercentageToCancel:)]) {
        CGFloat nonDismissableRadius = (self.nonDismissingRadius)? self.nonDismissingRadius.doubleValue : DEFAULT_RADIUS;
        CGFloat percentage = [self percentageDismissableWithDissmissableRadius:nonDismissableRadius centerReference:gesture.view.center currentViewCenter:self.animator.referenceView.center];
//        CGPoint nonDismissingFrameOrigin = self.nonDismissingFrame.origin;
//        CGPoint centerReferenceView = self.animator.referenceView.center;
//        CGFloat viewDistanceFromCenter = sqrt(pow(gesture.view.center.x - centerReferenceView.x, 2.0)+pow(gesture.view.center.y - centerReferenceView.y, 2.0));
//        CGFloat nonDismissingFrameDistanceFromCenter = sqrt(pow(nonDismissingFrameOrigin.x - centerReferenceView.x, 2.0)+pow(nonDismissingFrameOrigin.y - centerReferenceView.y, 2.0));
//        CGFloat percentage = (viewDistanceFromCenter/nonDismissingFrameDistanceFromCenter > 1)? 1 : viewDistanceFromCenter/nonDismissingFrameDistanceFromCenter;
        [self.delegate swarmDismissableViewManualTraslationDidMoveWithPercentageToCancel:percentage];
    }
    
    CGFloat rotation = atan2(gesture.view.transform.b, gesture.view.transform.a);
    //NSLog(@"rotation: %lf", rotation);
    CGFloat xDisplacement = [gesture locationInView:self.animator.referenceView].x - self.oldPosition.x;
    
    CGFloat translationAngle = (M_PI / 12.0);
    if (self.maxAngle) {
        translationAngle = (*self.maxAngle > 0)? *self.maxAngle : -(*self.maxAngle);
    }
    
    CGPoint gestureViewCenter = [self.animator.referenceView convertPoint:gesture.view.center toView:gesture.view];
    CGPoint touchLocationInGestureView = [gesture locationInView:gesture.view];
    if (touchLocationInGestureView.y > gestureViewCenter.y) {
        
        if (xDisplacement < 0 && rotation > translationAngle) {
            self.itemBehavior.allowsRotation = NO;
        } else if (xDisplacement > 0 && rotation < -translationAngle){
            self.itemBehavior.allowsRotation = NO;
        } else {
            self.itemBehavior.allowsRotation = YES;
        }
    } else {
        if (xDisplacement < 0 && rotation < -translationAngle) {
            self.itemBehavior.allowsRotation = NO;
        } else if (xDisplacement > 0 && rotation > translationAngle){
            self.itemBehavior.allowsRotation = NO;
        } else {
            self.itemBehavior.allowsRotation = YES;
        }
    }
    
    self.attachment.anchorPoint = [gesture locationInView:self.animator.referenceView];
    self.oldPosition = [gesture locationInView:self.animator.referenceView];
}

- (void)draggingEnded:(UIPanGestureRecognizer *)gesture{
    [self.animator removeBehavior:self.itemBehavior];
    [self.animator removeBehavior:self.attachment];
    
    CGFloat nonDismissableRadius = (self.nonDismissingRadius)? self.nonDismissingRadius.doubleValue : DEFAULT_RADIUS;
    CGFloat percentage = [self percentageDismissableWithDissmissableRadius:nonDismissableRadius centerReference:gesture.view.center currentViewCenter:self.animator.referenceView.center];
    
    if (self.dismissable && percentage == 1) { // view should be dismissed
    //if (self.dismissable && !CGRectContainsPoint(self.nonDismissingFrame, gesture.view.center)) { // view should be dismissed
        
        
        
        if (!self.gravityBehavior) {
            UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[gesture.view]];
            self.gravityBehavior = gravityBehavior;
            if (self.gravity) {
                self.gravityBehavior.magnitude = *self.gravity;
            } else {
                self.gravityBehavior.magnitude = 0.5;
            }
            [self.animator addBehavior:self.gravityBehavior];
        }
        
        CGPoint v = [gesture velocityInView:self.animator.referenceView];
        CGFloat magnitude = sqrtf(powf(v.x, 2.0)+powf(v.y, 2.0));
        CGFloat angle = atan2(v.y, v.x);
        
        magnitude /= 45;
        
        CGPoint locationInView = [gesture locationInView:self.animator.referenceView];
        UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[gesture.view] mode:UIPushBehaviorModeInstantaneous];
        [pushBehavior setTargetOffsetFromCenter:UIOffsetMake(locationInView.x - gesture.view.center.x, locationInView.y - gesture.view.center.y) forItem:gesture.view];
        pushBehavior.magnitude = magnitude;
        pushBehavior.angle = angle;
        
        [self.animator addBehavior:pushBehavior];
        [self.animator removeBehavior:self.attachment];
        gesture.view.userInteractionEnabled = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(swarmDismissableViewWillStartDismissAnimationWithDynamics)]) {
            [self.delegate swarmDismissableViewWillStartDismissAnimationWithDynamics];
        }
        [self performSelector:@selector(checkForFinishedDismissingView) withObject:nil afterDelay:0.1];
    } else { //view should be put back in it's original position
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(swarmDismissableViewCanceledDismissWithDynamics)]) {
            [self.delegate swarmDismissableViewCanceledDismissWithDynamics];
        }
        
        UIView *view = self.animator.referenceView;
        self.animator = nil;
        
        CGFloat cancelDuration = 0.3;
        if (self.cancelAnimationDuration) {
            cancelDuration = self.cancelAnimationDuration.doubleValue;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(swarmDismissableViewWillStartDismissCancelAnimationWithDuration:)]) {
            [self.delegate swarmDismissableViewWillStartDismissCancelAnimationWithDuration:cancelDuration];
        }
        [UIView animateWithDuration:cancelDuration animations:^{
            gesture.view.center = view.center;
            gesture.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(swarmDismissableViewDidFinishDismissCancelAnimation)]) {
                [self.delegate swarmDismissableViewDidFinishDismissCancelAnimation];
            }
        }];
    }
    
}

-(void)checkForFinishedDismissingView{
    UIView *view = self.superview;
    if (self.locationReferenceView) {
        view = self.locationReferenceView;
    }
    if (!CGRectIntersectsRect(view.frame, [view.superview convertRect:self.frame fromView:view])) {
        self.animator = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(swarmDismissableViewDidFinishDismissAnimationWithDynamics)]) {
            [self.delegate swarmDismissableViewDidFinishDismissAnimationWithDynamics];
        }
        [self removeFromSuperview];
    } else {
        [self performSelector:@selector(checkForFinishedDismissingView) withObject:nil afterDelay:0.1];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
