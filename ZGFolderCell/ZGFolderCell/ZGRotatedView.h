//
//  ZGRotatedView.h
//  ZGFolderCell
//
//  Created by offcn_zcz32036 on 2018/6/1.
//  Copyright © 2018年 cn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZGRotatedView : UIView
@property (nonatomic, assign) BOOL hiddenAfterAnimation;
@property (nonatomic, strong) ZGRotatedView * backView;

- (CATransform3D)transform3d;

- (void)addBackView:(CGFloat)height color:(UIColor *)color;

- (void)foldingAnimation:(NSString *)timing from:(CGFloat)from to:(CGFloat)to duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay hidden:(BOOL)hidden;
@end
