//
//  DCLiveLikeAnimation.m
//  DCLiveLikeAnimationDemo
//
//  Created by 梁晓龙 on 7/30/21.
//

#import "DCLiveLikeAnimation.h"
///T
#import "DCLiveLikeNumberLabel.h"

#define ADAPTATIONRATIO   [UIScreen mainScreen].bounds.size.width / 750.0f
#define ANGLEVALUE(angle) ((angle) * M_PI / 180.0)//角度数值转换宏
#define Duration 0.3
#define OFFSETCENTER_Y  30.f

@interface DCLiveLikeAnimation ()<CAAnimationDelegate>
@property (nonatomic, strong) NSArray<UIImage *> *elements;
@property (nonatomic, strong) DCLiveLikeNumberLabel *numberLbl;
@property (nonatomic, assign) NSInteger lastTime;
@end

@implementation DCLiveLikeAnimation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lastTime = 1;
    }
    return self;
}

#pragma mark - Public Methods

- (void)createAnimationWithTouch:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event isRandom:(BOOL)isRandom{
    UITouch *touch = [touches anyObject];
    if (self.lastTime >= touch.tapCount) {
        if (self.completeBlock) {
            self.completeBlock(self.lastTime);
        }
        self.lastTime = 1;
    } else {
        self.lastTime = touch.tapCount;
    }
    
    CGPoint point = [touch locationInView:touch.view];
    CGFloat X = point.x;
    CGFloat Y = point.y;
    if (point.y > OFFSETCENTER_Y) {
        Y = (point.y - OFFSETCENTER_Y);
    }
    
    if (touch.tapCount < 1) return;
    if (touch.tapCount == 1) { ///单次点击
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ADAPTATIONRATIO *80.f, ADAPTATIONRATIO *80.f)];
        imgView.image = self.elements[arc4random() % self.elements.count];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.center = CGPointMake(X, Y);
        imgView.hidden = YES;
        [touch.view addSubview:imgView];
        [self handleClickGroupAnmation:imgView];
    } else if (touch.tapCount <= 10) { ///多次点击
        if (![touch.view.subviews containsObject:self.numberLbl]) {
            [touch.view addSubview:self.numberLbl];
        }
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ADAPTATIONRATIO *80.f, ADAPTATIONRATIO *80.f)];
        imgView.image = self.elements[arc4random() % self.elements.count];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.center = CGPointMake(X, Y);
        [touch.view addSubview:imgView];
        [self handleClickGroupAnmation:imgView];
        [self shakeAnimationWithNumber:touch.tapCount point:point];
    } else { ///连续点击
        if (![touch.view.subviews containsObject:self.numberLbl]) {
            [touch.view addSubview:self.numberLbl];
        }
        [self handleUnionStrikeGrounpAnmation:touch.view point:CGPointMake(X, Y)];
        [self shakeAnimationWithNumber:touch.tapCount point:point];
    }
}


#pragma mark - Private Methods
///连乘单击动画
- (void)handleClickGroupAnmation:(UIView *)targetView {
    ///1.放大帧动画
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    
    CAKeyframeAnimation* scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.calculationMode = kCAAnimationCubic;
    scaleAnimation.duration = 0.6f;
    scaleAnimation.beginTime = 0.0f;
    scaleAnimation.values = values;
    scaleAnimation.keyTimes = @[@0,@0.1,@0.3,@0.6];
    
    ///2.旋转动画
    CAKeyframeAnimation *roationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    roationAnimation.calculationMode = kCAAnimationCubicPaced;
    roationAnimation.beginTime = 0.1f;
    roationAnimation.duration = 0.2f;
    roationAnimation.values = @[@(ANGLEVALUE(-5)),@(ANGLEVALUE(5)),@(ANGLEVALUE(-5))];
    
    ///3.透明度
    CAKeyframeAnimation *fadeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.calculationMode = kCAAnimationCubic;
    fadeAnimation.beginTime = 0.3f;
    fadeAnimation.duration = 0.3f;
    fadeAnimation.values = @[@(1.0),@(0)];
    
    ///4.创建动画组
    CAAnimationGroup *animationGroup=[CAAnimationGroup animation];
    animationGroup.duration = 0.6f;//设置动画时间，如果动画组中动画已经设置过动画属性则不再生效
    animationGroup.animations = @[scaleAnimation,roationAnimation,fadeAnimation];
    animationGroup.delegate = self;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    [animationGroup setValue:targetView forKey:@"ParentView"];
    [targetView.layer addAnimation:animationGroup forKey:nil];
}

///连乘爆炸💥动画
- (void)handleUnionStrikeGrounpAnmation:(UIView *)targetView point:(CGPoint)initialPoint{
    ///粒子源
    ///1.创建发射器
    CAEmitterLayer *emitterLayer = [[CAEmitterLayer alloc]init];
    ///2.设置发射器的位置
    emitterLayer.position = initialPoint;
    emitterLayer.emitterShape = kCAEmitterLayerPoint;
    emitterLayer.masksToBounds = NO;
    emitterLayer.renderMode = kCAEmitterLayerBackToFront;
    emitterLayer.preservesDepth = YES;
    ///3.创建多个粒子
    NSMutableArray *cellArr = [NSMutableArray array];
    for (int i = 0 ; i < self.elements.count; i++) {
        CAEmitterCell *cell = [[CAEmitterCell alloc]init];
        ///设置粒子每秒弹出的个数
        cell.birthRate = 3;
        ///设置粒子的存活时间
        cell.lifetime = 1;
        cell.lifetimeRange = 1;
        ///设置粒子的大小
        cell.scale = 0.3;
        ///设置粒子透明度
        cell.alphaRange = 1;
        cell.alphaSpeed = -1.5;
        ///设置下落效果
        cell.yAcceleration = 1000;
        ///设置粒子速度
        cell.velocity = 1500;
        cell.velocityRange = 1500;
        ///设置粒子方向
        cell.emissionLongitude = -M_PI_2;
        cell.emissionRange = M_PI_2;
        ///设置粒子展示的图片
        cell.contents = (__bridge id _Nullable)(self.elements[i].CGImage);
        ///将创建出来的cell加入到数组中
        [cellArr addObject:cell];
    }
    emitterLayer.emitterCells = cellArr;
    ///4.将发射器的layer添加到父layer中
    [targetView.layer addSublayer:emitterLayer];
    ///5.停止发射
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.numberLbl.upvoteCount--;
        emitterLayer.birthRate = 0;//停止发射
        [emitterLayer removeFromSuperlayer];
    });
}

///MARK:设置连乘数字
- (void)shakeAnimationWithNumber:(NSInteger)number point:(CGPoint)initialPoint{
    self.numberLbl.center = CGPointMake(initialPoint.x, (initialPoint.y - 70.f));
    [self startShakeAnimationWithNumber:number completion:nil];
}

- (void)startShakeAnimationWithNumber:(NSInteger)number completion:(void (^)(BOOL finished))block {
    ///设置富文本
    NSString *textStr = [NSString stringWithFormat:@"X %ld",number];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]initWithString:textStr];
    ///X
    NSDictionary *x_attributeDict = @{
        NSFontAttributeName:[UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold]
    };
    NSRange x_range = [textStr rangeOfString:@"X"];
    if (x_range.location == NSNotFound) {
        x_range = NSMakeRange(0, 0);
    }
    [attributeStr addAttributes:x_attributeDict range:x_range];
    ///震动反馈
    [self feedBackGeneratorAction];
    ///设置连乘数
    self.numberLbl.attributedText = attributeStr;
    self.numberLbl.upvoteCount++;
}

///振动
- (void)feedBackGeneratorAction {
    UIImpactFeedbackGenerator * impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleHeavy];
    [impactLight impactOccurred];
}


#pragma mark - Delegate Methods
///动画开始
- (void)animationDidStart:(CAAnimation *)anim {
    if ([anim isKindOfClass:CAAnimationGroup.class]) {
        CAAnimationGroup *animationGroup = (CAAnimationGroup*)anim;
        UIView *parentView = [animationGroup valueForKey:@"ParentView"];
        parentView.hidden = NO;
    }
}
///动画结束
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([anim isKindOfClass:CAAnimationGroup.class]) {
        self.numberLbl.upvoteCount--;
        CAAnimationGroup *animationGroup = (CAAnimationGroup*)anim;
        UIView *parentView = [animationGroup valueForKey:@"ParentView"];
        [parentView.layer removeAllAnimations];
        [parentView removeFromSuperview];
    }
}


#pragma mark - Setter && Getter Methods
///元素
- (NSArray<UIImage *> *)elements {
    if (!_elements) {
        _elements = @[
            [UIImage imageNamed:@"Element.bundle/element_car"],
            [UIImage imageNamed:@"Element.bundle/element_dropRobot"],
            [UIImage imageNamed:@"Element.bundle/element_dropstar"],
            [UIImage imageNamed:@"Element.bundle/element_heart"],
            [UIImage imageNamed:@"Element.bundle/element_money"],
            [UIImage imageNamed:@"Element.bundle/element_present"],
            [UIImage imageNamed:@"Element.bundle/element_zan"]
        ];
    }
    return _elements;
}

///连乘数
- (DCLiveLikeNumberLabel *)numberLbl {
    if (!_numberLbl) {
        _numberLbl  = [[DCLiveLikeNumberLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100, 40)];
        _numberLbl.backgroundColor = [UIColor clearColor];
        _numberLbl.borderColor     = [UIColor whiteColor];
        _numberLbl.textColor       = [UIColor blueColor];
        _numberLbl.font            = [UIFont systemFontOfSize:30 weight:UIFontWeightSemibold];
        _numberLbl.textAlignment   = NSTextAlignmentCenter;
        _numberLbl.alpha           = 0.0;
        _numberLbl.tag = 1000001;
    }
    return _numberLbl;
}

@end
