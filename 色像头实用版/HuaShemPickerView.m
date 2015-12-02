//
//  HuaShemPickerView.m
//  摄像头
//
//  Created by huchunyuan on 15/11/9.
//  Copyright © 2015年 huchunyuan. All rights reserved.
//

#import "HuaShemPickerView.h"
#import "MBProgressHUD+MJ.h"
/** 二进制码转RGB */
#define UIColorFromRGBValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface HuaShemPickerView ()
// 底部控制按钮
@property (strong, nonatomic) UIView *controllView;

@property (strong, nonatomic) UIImageView *startImageView;

@property (assign, nonatomic) CGFloat buttonWidth;



@property (assign, nonatomic) NSInteger index;
@end

@implementation HuaShemPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 添加底部View
        _controllView = [[UIView alloc] initWithFrame:CGRectMake(0,frame.size.height - 110, frame.size.width, 110)];
        _controllView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [self addSubview:self.controllView];
        
        // 开始按钮
        self.buttonWidth = 80;
        _startImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-40, _controllView.frame.size.height/2-40, _buttonWidth, _buttonWidth)];
        _startImageView.userInteractionEnabled = YES;
        _startImageView.image = [UIImage imageNamed:@"开始"];
        [_controllView addSubview:_startImageView];
        
        // 长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(start:)];
        longPress.minimumPressDuration = 0.1;
        [longPress setAllowableMovement:100];
        [_startImageView addGestureRecognizer:longPress];
        
        // 进度条
        _sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_controllView.frame)-8, frame.size.width, 8)];
        _sliderView.backgroundColor = UIColorFromRGBValue(0x82dfb0);
        [self addSubview:_sliderView];
        _sliderRect = _sliderView.frame;
        // label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2-40, CGRectGetMinY(_sliderView.frame)-40, 80, 20)];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = UIColorFromRGBValue(0x82dfb0);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"向上取消";
        [self addSubview:label];
        
    }
    return self;
}
// 长按方法
- (void)start:(UILongPressGestureRecognizer *)longPress{
    // 开始
    if (longPress.state == UIGestureRecognizerStateBegan){

        _index = 1;
        [self passIndex:1];
    }
    // 滑出结束
    if ([longPress locationInView:_startImageView].y < -10 ||
        [longPress locationInView:_startImageView].y - _buttonWidth > 10|
        [longPress locationInView:_startImageView].x < -10 ||
        [longPress locationInView:_startImageView].x - _buttonWidth > 10) {

        if (_index == 1) {
            [self passIndex:0];
        }
        _index = 0;
        
    }
    // 松手
    if (longPress.state == UIGestureRecognizerStateEnded) {

        if (_index == 1) {
            [self passIndex:0];
        }
        _index = 0;
    }
    
}
- (void)passIndex:(NSInteger)index{
    [_delegate changeValuePassIndex:index];

    if (index == 1) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"All Alonge With You.mp3" withExtension:nil];
        _music = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [_music prepareToPlay];
        [_music play];
        [UIView animateWithDuration:5 animations:^{
            _sliderView.frame = CGRectMake(self.frame.size.width/2, _sliderRect.origin.y, 0, 8);
        } completion:^(BOOL finished) {
           _sliderView.frame = _sliderRect;

            [_music stop];
            [MBProgressHUD showMessage:@"正在处理"];
        }];
    }else{
        [_sliderView.layer removeAllAnimations];
    }
}

@end
