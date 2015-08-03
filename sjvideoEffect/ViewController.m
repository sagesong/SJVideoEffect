//
//  ViewController.m
//  sjvideoEffect
//
//  Created by Lightning on 15/8/3.
//  Copyright (c) 2015年 Lightning. All rights reserved.
//

#import "ViewController.h"
#import "SJplayView.h"
#import "GPUImage.h"

@interface ViewController ()<AVPlayerItemOutputPullDelegate>
{
    CADisplayLink * _link;
    dispatch_queue_t _videoQueue;
    AVPlayerItemVideoOutput *_videoOutput;
    AVPlayer *_player;
    GPUImageMovie *_movie;
}


@property (nonatomic ,weak) SJplayView * playerView;
@property (nonatomic ,strong) AVPlayerItem *playerItem;

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_link setPaused:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallBack:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [_link setPaused:YES];
    
    _videoQueue = dispatch_queue_create("video source queue", DISPATCH_QUEUE_SERIAL);
    
    [self loadItem];
}

- (void)setupUI
{
    SJplayView * playerView = [[SJplayView alloc] init];
    [self.view addSubview:playerView];
    self.playerView = playerView;
    self.playerView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 200);
    self.playerView.backgroundColor = [UIColor redColor];
    
    UIButton *start = [UIButton buttonWithType:UIButtonTypeCustom];
    [start setTitle:@"开始" forState:UIControlStateNormal];
    [start addTarget:self action:@selector(startBtnclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:start];
    start.frame = CGRectMake(0, 300, 60, 60);
    start.backgroundColor = [UIColor blueColor];
    
    UIButton *stop = [UIButton buttonWithType:UIButtonTypeCustom];
    [stop setTitle:@"暂停" forState:UIControlStateNormal];
    [stop addTarget:self action:@selector(stopBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stop];
    stop.frame = CGRectMake(200, 300, 60, 60);
    stop.backgroundColor = [UIColor blueColor];

}

- (void)startBtnclick
{
    [_player play];
}

- (void)stopBtnClick
{
    [_player pause];
}

- (void)loadItem
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
//    GPUImageMovie *movie = [[GPUImageMovie alloc] initWithPlayerItem:item];
//    _movie = movie;
//    [movie startProcessing];
    assert(item);
    self.playerItem = item;
    AVPlayerLayer *layer = (AVPlayerLayer *)self.playerView.layer;
    AVPlayer *plaer = [[AVPlayer alloc] initWithPlayerItem:item];
    [layer setPlayer:plaer];
    _player = plaer;
//    [plaer play];
    
    // video output
    NSDictionary *dict = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    AVPlayerItemVideoOutput *videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:dict];
    [videoOutput setDelegate:self queue:_videoQueue];
    _videoOutput = videoOutput;
    [self.playerItem addOutput:videoOutput];
//    [videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.1];  
}

- (void)displayLinkCallBack:(CADisplayLink *)link
{
//    NSLog(@"diplayer link call back");
    CFTimeInterval nextVideoTime = link.timestamp + link.duration;
    CMTime outputItemTime = [_videoOutput itemTimeForHostTime:nextVideoTime];
    
    if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        CVPixelBufferRef pixelBuff = [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        NSLog(@"pixel buffer - %p",pixelBuff);
        CMTimeShow(outputItemTime);
        if (pixelBuff) {
            [self processPixelBuff:pixelBuff withSampleTime:outputItemTime];
        }
    }
    
}


- (void)processPixelBuff:(CVPixelBufferRef )pixelBuffer withSampleTime:(CMTime)sampleTime
{
    
}

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
    // Restart display link.
    [_link setPaused:NO];
}

@end
