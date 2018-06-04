//
//  UIView+ZGSnapShot.m
//  ZGFolderCell
//
//  Created by offcn_zcz32036 on 2018/6/1.
//  Copyright © 2018年 cn. All rights reserved.
//

#import "UIView+ZGSnapShot.h"

@implementation UIView (ZGSnapShot)
-(UIImage *)takeSnapShot:(CGRect)frame
{
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0);
    CGContextRef context=UIGraphicsGetCurrentContext();
    if (context==nil) {
        return nil;
    }
    //根据x和y进行平移，x为正时往右移,y为正时往上移动
    CGContextTranslateCTM(context, -frame.origin.x, -frame.origin.y);
    [self.layer renderInContext:context];
    UIImage*image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
