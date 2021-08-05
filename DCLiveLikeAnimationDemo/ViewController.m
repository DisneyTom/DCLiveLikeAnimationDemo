//
//  ViewController.m
//  DCLiveLikeAnimationDemo
//
//  Created by 梁晓龙 on 7/30/21.
//

#import "ViewController.h"
///T
#import "DCLiveLikeAnimation.h"

@interface ViewController ()
@property (nonatomic, strong) DCLiveLikeAnimation *likeAnimation;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.likeAnimation = [[DCLiveLikeAnimation alloc]init];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.likeAnimation createAnimationWithTouch:touches withEvent:event isRandom:NO];
}

@end
