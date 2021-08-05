//
//  DCLiveLikeNumberLabel.h
//  DCLiveLikeAnimationDemo
//
//  Created by 梁晓龙 on 8/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCLiveLikeNumberLabel : UILabel
/**! 数字描边颜色*/
@property (nonatomic,strong) UIColor *borderColor;
/**! 展示状态*/
@property (nonatomic,assign) BOOL showState;
@property (nonatomic,assign) NSInteger upvoteCount;

/// 开始连乘动画
/// @param interval 动画时间
/// @param completion 动画完成回调
- (void)startAnimationDuration:(NSTimeInterval)interval
                    completion:(void (^)(BOOL finish))completion;

/// 展示
- (void)show;

/// 隐藏
- (void)hide;

@end

NS_ASSUME_NONNULL_END
