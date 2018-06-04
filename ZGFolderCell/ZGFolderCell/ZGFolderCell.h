//
//  ZGFolderCell.h
//  ZGFolderCell
//
//  Created by offcn_zcz32036 on 2018/6/1.
//  Copyright © 2018年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZGRotatedView.h"
#import "ZGFolderCell.h"
typedef NS_ENUM(NSInteger,AnimationType) {
    AnimationTypeOpen=0,
    AnimationTypeClose
};
@interface ZGFolderCell : UITableViewCell
/**
 当cell展开时显示
 */
@property(nonatomic,strong)UIView*containerView;
@property(nonatomic,strong)NSLayoutConstraint*containerViewTop;
/**
 当cell收起时显示
 */
@property(nonatomic,strong)ZGRotatedView*foregroundView;
@property(nonatomic,strong)NSLayoutConstraint*foregroundViewTop;
/**
 折叠元素的个数，默认为2
 */
@property(nonatomic,assign)NSInteger itemCount;
/**
 初始化，在创建cell时调用
 */
-(void)commonInit;
-(NSTimeInterval)animationDuration:(NSInteger)itemIndex type:(AnimationType)type;
-(void)unfold:(BOOL)value animated:(BOOL)animated completion:(void(^)(void))completion;
-(BOOL)isAnimating;
@end
