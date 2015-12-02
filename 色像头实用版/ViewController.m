//
//  ViewController.m
//  色像头实用版
//
//  Created by huchunyuan on 15/11/9.
//  Copyright © 2015年 huchunyuan. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "HuaShemPickerView.h"
#import "MBProgressHUD+MJ.h"
//#import "PreviewViewController.h"
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,HuaShemPickerViewDelegate>
/** 录像对象 */
@property (strong, nonatomic) UIImagePickerController *imagePicker;
/** 照片展示视图 */
@property (weak, nonatomic) IBOutlet UIImageView *photo;

/** 摄像控制面板 */
@property (strong, nonatomic) HuaShemPickerView *huashemPick;
/** 播放器，用于录制完视频后播放视频 */
@property (strong ,nonatomic) AVPlayer *player;
/** 提示视图 */
@property (strong, nonatomic) UIAlertController *alertC;
/** 播放音乐 */
//@property (strong, nonatomic)

#pragma mark - 点取消时 需要用的,用于删除视频


/** 合成后录像的地址 **/
@property (strong, nonatomic) NSString *syntheticMovieStr;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    _huashemPick = [[HuaShemPickerView alloc] initWithFrame:self.view.frame];
    _huashemPick.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
     [self.navigationController presentViewController:self.imagePicker animated:NO completion:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    
    
    
}
-(void)playbackFinished:(NSNotification *)notification{
        self.alertC = [UIAlertController alertControllerWithTitle:@"成功" message:@"播放完成" preferredStyle:(UIAlertControllerStyleAlert)];
    
        UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"使用" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    
        }];
        [_alertC addAction:actionConfirm];
    
    
        UIAlertAction *actionRepet = [UIAlertAction actionWithTitle:@"重复播放" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [_player seekToTime:(kCMTimeZero)];
            [_player play];
        }];
        [_alertC addAction:actionRepet];
    
        UIAlertAction *actionCancle = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
            
            
            //删除2个合成的视频
            
            NSString *tmp = NSTemporaryDirectory();
            
            NSFileManager *manager = [NSFileManager defaultManager];
            
            [manager removeItemAtPath:tmp error:nil];
            
            
            
            
            if([[NSFileManager defaultManager]fileExistsAtPath:self.syntheticMovieStr]) {
                [[NSFileManager defaultManager]removeItemAtPath:self.syntheticMovieStr error:nil];
            }
            
            
            
            [self.navigationController presentViewController:self.imagePicker animated:NO completion:nil];
        }];
        [_alertC addAction:actionCancle];
    
    
        [self.navigationController presentViewController:_alertC animated:YES completion:nil];
}


- (UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        //设置image picker的来源，这里设置为摄像头
        _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
        //设置使用哪个摄像头，这里设置为后置摄像头
        _imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;
        _imagePicker.mediaTypes=@[(NSString *)kUTTypeMovie];
        
        /** 设置 摄像头品质 **/
        _imagePicker.videoQuality=UIImagePickerControllerQualityTypeIFrame1280x720;
        _imagePicker.videoMaximumDuration = 10.0;
        _imagePicker.showsCameraControls = NO;
        _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
//        _imagePicker.mediaTypes = ;
        _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
//        _imagePicker.videoQuality = UIImagePickerControllerQualityType640x480;
        _imagePicker.view.frame = CGRectMake(50, 50, 100, 100);
//        _imagePicker.cameraViewTransform = CGAffineTransformMakeTranslation(0, 0);
//        _imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform,1, 1);
        _imagePicker.view.backgroundColor = [UIColor whiteColor];
        
        _imagePicker.cameraOverlayView =  _huashemPick;
        _imagePicker.allowsEditing=YES;//允许编辑
        _imagePicker.delegate=self;//设置代理，检测操作

        
        
    }
    return _imagePicker;
}
#pragma mark - UIImagePickerController代理方法
//完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    
    
        // 录制视频
        NSLog(@"video...");
    NSURL *urlVideo=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
    //视频来源路径
    NSURL   *video_inputFileUrl = urlVideo;
    
    
    //声音来源路径（最终混合的音频）
    NSURL *urlStrMusic = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"All Alonge With You" ofType:@"mp3"]];
    // 音频url
    NSURL   *audio_inputFileUrl = urlStrMusic;

    
    
    
    //最终合成输出路径
    NSString *documentsDirectory =[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSString *outputFilePath =[documentsDirectory stringByAppendingPathComponent:@"final_video.mp4"];
    // 输出url
    NSURL   *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    
    self.syntheticMovieStr = outputFilePath;
    
    //如果路径中存在 .mp4文件 删除
    if([[NSFileManager defaultManager]fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager]removeItemAtPath:outputFilePath error:nil];
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    // 创建可变的音频视频组合
    AVMutableComposition* mixComposition =[AVMutableComposition composition];
    
    // 视频采集
    AVURLAsset* videoAsset =[[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack =[mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVURLAsset *audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange =CMTimeRangeMake(kCMTimeZero,videoAsset.duration);//声音长度截取范围==视频长度
    
    
    
    
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    
    /** 下面方法 presetName:AVAssetExportPresetHighestQuality 高清程度 **/
    AVAssetExportSession *_assetExport = [[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    
    _assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    _assetExport.outputURL = outputFileUrl;

    _assetExport.shouldOptimizeForNetworkUse=YES;
    
    
        NSLog(@"%@",_assetExport.presetName);
    
    AVMutableVideoComposition * videoComposition = [AVMutableVideoComposition videoComposition];
    
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    
    /** 视频出来后的尺寸 需要反着写 **/
    videoComposition.renderSize = CGSizeMake(720, 1280);

    

    
    AVMutableVideoCompositionInstruction      * instruction;
    AVMutableVideoCompositionLayerInstruction * layerInstruction;
    
    layerInstruction = [self layerInstructionAfterFixingOrientationForAsset:videoAsset forTrack:a_compositionVideoTrack atTime:video_timeRange.duration];
    
    
    instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    
    instruction.layerInstructions = @[ layerInstruction ];
    instruction.timeRange = a_compositionVideoTrack.timeRange; //CMTimeRangeMake(kCMTimeZero,
    videoComposition.instructions = @[instruction];
    
    [_assetExport setVideoComposition:videoComposition];
    
    [_assetExport setTimeRange:a_compositionVideoTrack.timeRange];
    
    
    
    
    
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^{
        
        
        NSLog(@"视频保存成功.");
        [self dismissViewControllerAnimated:YES completion:^{
            
            
            [MBProgressHUD hideHUD];
            
            [MBProgressHUD showSuccess:@"录像成功"];
            //录制完之后自动播放
            
            _player=[AVPlayer playerWithURL:outputFileUrl];
            AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
 
            playerLayer.frame= self.view.frame;

            [self.photo.layer addSublayer:playerLayer];
            
//
//                    NSString *urlStr=[urlVideo path];
//                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
////                        保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
//                        UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
//                    }
            
            
            [_player play];
        }];

    }];
     


}


/** 由于录制的视频为 逆时针旋转了90度 故 需要旋转回来 再合成 **/
- (AVMutableVideoCompositionLayerInstruction *)layerInstructionAfterFixingOrientationForAsset:(AVAsset *)inAsset forTrack:(AVMutableCompositionTrack *)inTrack atTime:(CMTime)inTime
{
    //FIXING ORIENTATION//
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:inTrack];
    AVAssetTrack *videoAssetTrack = [[inAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL  isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    
    if(videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)  {videoAssetOrientation_= UIImageOrientationRight; isVideoAssetPortrait_ = YES;}
    if(videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)  {videoAssetOrientation_ =  UIImageOrientationLeft; isVideoAssetPortrait_ = YES;}
    if(videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0)   {videoAssetOrientation_ =  UIImageOrientationUp;}
    if(videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {videoAssetOrientation_ = UIImageOrientationDown;}
    
    
    /** 需要设置对应的 1280 * 720  (需要720) **/
    CGFloat FirstAssetScaleToFitRatio = 720.0 / videoAssetTrack.naturalSize.width;
    
    if(isVideoAssetPortrait_) {
        FirstAssetScaleToFitRatio = 720.0 /videoAssetTrack.naturalSize.height;
        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
        [videolayerInstruction setTransform:CGAffineTransformConcat(videoAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
    }else{
        CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
        [videolayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(videoAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
    }
    [videolayerInstruction setOpacity:0.0 atTime:inTime];
    return videolayerInstruction;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
        NSLog(@"取消");
}
//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
        
    }else{

    }
}
- (void)changeValuePassIndex:(NSInteger)index{
    NSLog(@"%ld",(long)index);

    if (index == 1) {

        [_imagePicker startVideoCapture];
    }else if(index != 3){
        [_imagePicker stopVideoCapture];
        
    }else{
        [_imagePicker stopVideoCapture];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
