//
//  DCLiveLikeNumberLabel.m
//  DCLiveLikeAnimationDemo
//
//  Created by 梁晓龙 on 8/2/21.
//

#import "DCLiveLikeNumberLabel.h"

@implementation DCLiveLikeNumberLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.upvoteCount = 0;
    }
    return self;
}


#pragma mark - Public Methods
///展示
- (void)show {
    self.showState = YES;
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anima.fromValue = @0;
    anima.toValue = @1;
    anima.duration = 0.2;
    anima.removedOnCompletion = NO;
    anima.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:anima forKey:@"opacityAniamtion"];
}

///隐藏
- (void)hide {
    self.showState = NO;
    CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anima.fromValue = @1;
    anima.toValue = @0;
    anima.duration = 0.5;
    anima.removedOnCompletion = NO;
    anima.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:anima forKey:@"opacityAniamtion"];
}

///开启连乘动画
- (void)startAnimationDuration:(NSTimeInterval)interval completion:(void (^)(BOOL finish))completion {
    [UIView animateKeyframesWithDuration:interval delay:0 options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1/2.0 animations:^{
            self.transform = CGAffineTransformMakeScale(4, 4);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:1/4.0 relativeDuration:1/2.0 animations:^{
            self.transform = CGAffineTransformMakeScale(2, 2);
        }];
        
        [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/2.0 animations:^{
            self.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
        
    }];
}


#pragma mark - Override Methods

///绘制文字边框颜色
- (void)drawTextInRect:(CGRect)rect {
    UIColor *textColor = self.textColor;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 5);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = self.borderColor;
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
}


#pragma mark - Setter && Getter Methods

- (void)setUpvoteCount:(NSInteger)upvoteCount {
    if (upvoteCount < 0) {
        _upvoteCount = 0;
    } else {
        _upvoteCount = upvoteCount;
    }
    
    if (_upvoteCount <= 0 && self.showState) {
        [self hide];
    } else if (_upvoteCount > 0 && !self.showState) {
        [self show];
    }
}

@end
