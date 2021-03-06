//
//  ZGFolderCell.m
//  ZGFolderCell
//
//  Created by offcn_zcz32036 on 2018/6/1.
//  Copyright © 2018年 cn. All rights reserved.
//

#import "ZGFolderCell.h"
#import "UIView+ZGSnapShot.h"
@interface ZGFolderCell()
@property(nonatomic,strong)UIView*animationView;
@property(nonatomic,copy)NSArray*animationItemViews;
@property(nonatomic,strong)UIColor*backViewColor;
@property(nonatomic,assign)BOOL isUnfolded;
@property(nonatomic,strong)NSMutableArray*durationsForExpandedState;
@property(nonatomic,strong)NSMutableArray*durationsForCollapsedState;
@end
@implementation ZGFolderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}
#pragma  mark initialize
- (void)commonInit{
    [self configureDefaultState];
    self.durationsForExpandedState = [NSMutableArray array];
    self.durationsForCollapsedState = [NSMutableArray array];

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.containerView.layer.cornerRadius = self.foregroundView.layer.cornerRadius;
    self.containerView.layer.masksToBounds = YES;
}

- (void)configureDefaultState{
    //两个topConstraint一定要设置
    if(self.foregroundViewTop == nil || self.containerViewTop == nil){
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"set foregroundViewTop or containerViewTop outlets" userInfo:nil];
    }

    self.containerViewTop.constant = self.foregroundViewTop.constant;
    self.containerView.alpha = 0;

    NSLayoutConstraint * constraint = [self.foregroundView.constraints filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSLayoutConstraint * evaluatedObject, NSDictionary * bindings) {
        return evaluatedObject.firstAttribute == NSLayoutAttributeHeight && evaluatedObject.secondItem == nil;
    }]].firstObject;

    if(constraint){
        self.foregroundView.layer.anchorPoint = CGPointMake(0.5, 1);
        self.foregroundViewTop.constant += constraint.constant / 2;
    }

    self.foregroundView.layer.transform = [self.foregroundView transform3d];

    [self createAnimationView];
    [self.contentView bringSubviewToFront:self.foregroundView];
}

- (void)createAnimationView{
    self.animationView = [[UIView alloc] initWithFrame:self.containerView.frame];
    self.animationView.layer.cornerRadius = self.foregroundView.layer.cornerRadius;
    self.animationView.backgroundColor = [UIColor clearColor];
    self.animationView.translatesAutoresizingMaskIntoConstraints = NO;
    self.animationView.alpha = 0;

    [self.contentView addSubview:self.animationView];

    // copy constraints from containerView
    NSMutableArray<NSLayoutConstraint *> * newConstraits = [NSMutableArray array];
    for (NSLayoutConstraint * constraint in self.contentView.constraints) {
        UIView * item = constraint.firstItem;
        UIView * secondItem = constraint.secondItem;

        if(item && item == self.containerView){
            NSLayoutConstraint * newConstraint = [NSLayoutConstraint constraintWithItem:self.animationView attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:secondItem attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constraint.constant];
            [newConstraits addObject:newConstraint];
        }else if(secondItem && secondItem == self.containerView){
            NSLayoutConstraint * newConstraint = [NSLayoutConstraint constraintWithItem:item attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:self.animationView attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constraint.constant];
            [newConstraits addObject:newConstraint];
        }
    }
    [self.contentView addConstraints:newConstraits];

    for (NSLayoutConstraint * constraint in self.containerView.constraints) {
        UIView * item = constraint.firstItem;
        if(item && constraint.firstAttribute == NSLayoutAttributeHeight && item == self.containerView){
            NSLayoutConstraint * newConstraint = [NSLayoutConstraint constraintWithItem:self.animationView attribute:constraint.firstAttribute relatedBy:constraint.relation toItem:nil attribute:constraint.secondAttribute multiplier:constraint.multiplier constant:constraint.constant];

            [self.animationView addConstraint:newConstraint];
        }
    }
}

#pragma mark private

- (NSArray<ZGRotatedView *> *)createAnimationItemView{
    if(self.animationView == nil){
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Animation View should not be nil" userInfo:nil];
    }

    NSMutableArray<ZGRotatedView *> * items = [NSMutableArray array];
    [items addObject:self.foregroundView];

    NSMutableArray<ZGRotatedView *> * rotatedViews = [NSMutableArray array];

    NSArray * sortedArr = [self sortRotatedViewsInAnimationView];

    for (ZGRotatedView * itemView in sortedArr) {
        [rotatedViews addObject:itemView];
        if(itemView.backView){
            [rotatedViews addObject:itemView.backView];
        }
    }

    [items addObjectsFromArray:rotatedViews];
    return [items copy];
}

- (void)configureAnimationItems:(AnimationType)animationType{
    NSArray * animationViewSubViews = self.animationView.subviews;
    if(animationViewSubViews == nil){
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Subviews of animation view should not be nil" userInfo:nil];
    }

    NSArray * arr = [self rotatedViewsInAnimationView];

    //没看懂源码这波操作
    //    if(animationType == AnimationTypeOpen){
    //        for (ZGRotatedView * view in arr) {
    //            view.alpha = 0;
    //        }
    //    }else{
    //        for (ZGRotatedView * view in arr) {
    //            if(animationType == AnimationTypeOpen){
    //                view.alpha = 0;
    //            }else{
    //                view.alpha = 1;
    //                view.backView.alpha = 0;
    //            }
    //        }
    //    }

    for (ZGRotatedView * view in arr) {
        if(animationType == AnimationTypeOpen){
            view.alpha = 0;
        }else{
            view.alpha = 1;
            view.backView.alpha = 0;
        }

    }
}



- (void)addImageItemsToAnimationView{
    self.containerView.alpha = 1;
    CGSize containerViewSize = self.containerView.bounds.size;
    CGSize foregroundViewSize = self.foregroundView.bounds.size;

    // added first item
    UIImage * image = [self.containerView takeSnapShot:CGRectMake(0, 0, containerViewSize.width, foregroundViewSize.height)];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = 0;
    imageView.layer.cornerRadius = self.foregroundView.layer.cornerRadius;
    [self.animationView addSubview:imageView];

    // added second item
    image = [self.containerView takeSnapShot:CGRectMake(0, foregroundViewSize.height, containerViewSize.width, foregroundViewSize.height)];
    imageView = [[UIImageView alloc] initWithImage:image];
    ZGRotatedView * rotatedView = [[ZGRotatedView alloc] initWithFrame:imageView.frame];
    rotatedView.tag = 1;
    rotatedView.layer.anchorPoint = CGPointMake(0.5, 0);
    rotatedView.layer.transform = [rotatedView transform3d];

    [rotatedView addSubview:imageView];
    [self.animationView addSubview:rotatedView];
    rotatedView.frame = CGRectMake(imageView.frame.origin.x, foregroundViewSize.height, containerViewSize.width, foregroundViewSize.height);

    // added other views
    CGFloat itemHeight = (containerViewSize.height - 2 * foregroundViewSize.height) / (self.itemCount - 2);

    if(self.itemCount == 2){
        // decrease containerView height or increase itemCount
        NSAssert(containerViewSize.height - 2 * foregroundViewSize.height == 0, @"containerView.height too high");
    }else{
        // decrease containerView height or increase itemCount
        NSAssert(containerViewSize.height - 2 * foregroundViewSize.height >= itemHeight, @"containerView.height too high");
    }

    CGFloat yPosition = 2 * foregroundViewSize.height;
    NSInteger tag = 2;

    for (int i = 2; i < self.itemCount; i++) {
        image = [self.containerView takeSnapShot:CGRectMake(0, yPosition, containerViewSize.width, itemHeight)];

        imageView = [[UIImageView alloc] initWithImage:image];
        ZGRotatedView * rotatedView = [[ZGRotatedView alloc] initWithFrame:imageView.frame];

        [rotatedView addSubview:imageView];
        rotatedView.layer.anchorPoint = CGPointMake(0.5, 0);
        rotatedView.layer.transform = [rotatedView transform3d];
        [self.animationView addSubview:rotatedView];
        rotatedView.frame = CGRectMake(0, yPosition, rotatedView.bounds.size.width, itemHeight);
        rotatedView.tag = tag;

        yPosition += itemHeight;
        tag += 1;
    }

    self.containerView.alpha = 0;

    if(self.animationView){
        // added back view
        ZGRotatedView * previousView;

        NSArray * sortedArr = [self sortRotatedViewsInAnimationView];

        for (ZGRotatedView * container in sortedArr) {
            [previousView addBackView:container.bounds.size.height color:self.backViewColor];
            previousView = container;
        }
    }

    self.animationItemViews = [self createAnimationItemView];
}

- (NSArray *)rotatedViewsInAnimationView{
    NSArray * arr = [self.animationView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView * evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isMemberOfClass:[ZGRotatedView class]] && evaluatedObject.tag > 0 && evaluatedObject.tag < self.animationView.subviews.count;
    }]];

    return arr;
}

- (NSArray *)sortRotatedViewsInAnimationView{
    NSArray * arr = [self rotatedViewsInAnimationView];

    NSArray * sortedArr = [arr sortedArrayUsingComparator:^NSComparisonResult(UIView * obj1, UIView * obj2) {
        if(obj1.tag < obj2.tag){
            return NSOrderedAscending;
        }
        if(obj1.tag > obj2.tag){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];

    return sortedArr;
}

- (void)removeImageItemsFromAnimationView{
    if(self.animationView == nil){
        return;
    }

    for (UIView * view in self.animationView.subviews) {
        [view removeFromSuperview];
    }
}

#pragma mark public

/// Unfold cell.
///
/// - Parameters:
///   - value: unfold = true; collapse = false.
///   - animated: animate changes.
///   - completion: A block object to be executed when the animation sequence ends.
- (void)unfold:(BOOL)value animated:(BOOL)animated completion:(void (^)(void))completion{
    if(animated){
        value ? [self openAnimation:completion] : [self closeAnimation:completion];
    } else {
        self.foregroundView.alpha = value ? 0 : 1;
        self.containerView.alpha = value ? 1 : 0;
    }
}

- (BOOL)isAnimating{
    return self.animationView.alpha == 1 ? YES : NO;
}

- (NSTimeInterval)animationDuration:(NSInteger)itemIndex type:(AnimationType)type{
    return type == AnimationTypeClose ? [self.durationsForCollapsedState[itemIndex] doubleValue] : [self.durationsForExpandedState[itemIndex] doubleValue];
}

#pragma mark animations

- (NSArray *)durationSequence:(AnimationType)type{
    NSMutableArray * durations = [NSMutableArray array];
    for (int i = 0; i < self.itemCount - 1; i++) {
        NSTimeInterval duration = [self animationDuration:i type:type];
        [durations addObject:[NSNumber numberWithDouble:duration / 2.0]];
        [durations addObject:[NSNumber numberWithDouble:duration / 2.0]];
    }

    return [durations copy];
}

- (void)openAnimation:(void (^)(void))completion{
    self.isUnfolded = YES;
    [self removeImageItemsFromAnimationView];
    [self addImageItemsToAnimationView];

    self.animationView.alpha = 1;
    self.containerView.alpha = 0;

    NSArray * durations = [self durationSequence:AnimationTypeOpen];

    NSTimeInterval delay = 0;
    NSString * timing = kCAMediaTimingFunctionEaseIn;
    CGFloat from = 0.0;
    CGFloat to = -M_PI_2;
    BOOL hidden = YES;
    [self configureAnimationItems:AnimationTypeOpen];

    if(self.animationItemViews == nil){
        return;
    }

    for (int index = 0; index < self.animationItemViews.count; index++) {
        ZGRotatedView * animatedView = self.animationItemViews[index];

        [animatedView foldingAnimation:timing from:from to:to duration:[durations[index] doubleValue] delay:delay hidden:hidden];

        from = from == 0.0 ? M_PI_2 : 0.0;
        to = to == 0.0 ? -M_PI_2 : 0.0;
        timing = timing == kCAMediaTimingFunctionEaseIn ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn;
        hidden = !hidden;
        delay += [durations[index] doubleValue];
    }

    UIView * firstItemView = [self.animationView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView * evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.tag == 0;
    }]].firstObject;
    firstItemView.layer.masksToBounds = YES;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([durations[0] doubleValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        firstItemView.layer.cornerRadius = 0;
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.animationView.alpha = 0;
        self.containerView.alpha = 1;
        if(completion){
            completion();
        }
    });
}

- (void)closeAnimation:(void (^)(void))completion{
    self.isUnfolded = NO;
    [self removeImageItemsFromAnimationView];
    [self addImageItemsToAnimationView];

    if(self.animationItemViews == nil){
        return;
    }

    self.animationView.alpha = 1;
    self.containerView.alpha = 0;

    NSArray * durations = [[[self durationSequence:AnimationTypeClose] reverseObjectEnumerator] allObjects];

    NSTimeInterval delay = 0;
    NSString * timing = kCAMediaTimingFunctionEaseIn;
    CGFloat from = 0.0;
    CGFloat to = M_PI_2;
    BOOL hidden = YES;
    [self configureAnimationItems:AnimationTypeClose];

    if(durations.count < self.animationItemViews.count){
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"wrong override func animationDuration(itemIndex:NSInteger, type:AnimationType)-> NSTimeInterval" userInfo:nil];
    }

    for (int index = 0; index < self.animationItemViews.count; index++) {
        ZGRotatedView * animatedView = [[[self.animationItemViews reverseObjectEnumerator] allObjects] objectAtIndex:index];

        [animatedView foldingAnimation:timing from:from to:to duration:[durations[index] doubleValue] delay:delay hidden:hidden];

        from = from == 0.0 ? -M_PI_2 : 0.0;
        to = to == 0.0 ? M_PI_2 : 0.0;
        timing = timing == kCAMediaTimingFunctionEaseIn ? kCAMediaTimingFunctionEaseOut : kCAMediaTimingFunctionEaseIn;
        hidden = !hidden;
        delay += [durations[index] doubleValue];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.animationView.alpha = 0;
        if(completion){
            completion();
        }
    });

    UIView * firstItemView = [self.animationView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView * evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.tag == 0;
    }]].firstObject;
    firstItemView.layer.cornerRadius = 0;
    firstItemView.layer.masksToBounds = YES;

    id durationFirst = durations.firstObject;
    if(durationFirst){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((delay - [durationFirst doubleValue] * 2) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            firstItemView.layer.cornerRadius = self.foregroundView.layer.cornerRadius;
            [firstItemView setNeedsDisplay];
            [firstItemView setNeedsLayout];
        });
    }
}

#pragma mark getters
- (NSInteger)itemCount{
    if(_itemCount == 0){
        _itemCount = 2;
    }

    return _itemCount;
}

- (UIColor *)backViewColor{
    if(_backViewColor == nil){
        _backViewColor = [UIColor colorWithRed:247.0 / 255 green:239.0 / 255 blue:247.0 / 255 alpha:1.0];
    }

    return _backViewColor;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}
@end
