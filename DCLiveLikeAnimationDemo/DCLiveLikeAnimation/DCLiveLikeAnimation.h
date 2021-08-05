//
//  DCLiveLikeAnimation.h
//  DCLiveLikeAnimationDemo
//
//  Created by 梁晓龙 on 7/30/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ComboNumberBlock)(NSInteger praiseNumber);

@interface DCLiveLikeAnimation : NSObject

/**! 点赞数*/
@property (nonatomic, copy) ComboNumberBlock completeBlock;

/// 创建点击动画
/// @param touches 手指集
/// @param event 事件
/// @param isRandom 是否随机
- (void)createAnimationWithTouch:(NSSet<UITouch *> *)touches
                       withEvent:(UIEvent *)event
                        isRandom:(BOOL)isRandom;

@end

NS_ASSUME_NONNULL_END
