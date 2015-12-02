//
//  HuaShemPickerView.h
//  摄像头
//
//  Created by huchunyuan on 15/11/9.
//  Copyright © 2015年 huchunyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol HuaShemPickerViewDelegate <NSObject>

- (void)changeValuePassIndex:(NSInteger)index;

@end
@interface HuaShemPickerView : UIView
// 代理
@property (assign, nonatomic) id<HuaShemPickerViewDelegate>delegate;
@property (nonatomic,strong)AVAudioPlayer *music;
@property (strong, nonatomic) UIView *sliderView;
@property (assign, nonatomic) CGRect sliderRect;
@end
