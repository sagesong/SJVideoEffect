//
//  ViewController.m
//  sjvideoEffect
//
//  Created by Lightning on 15/8/3.
//  Copyright (c) 2015年 Lightning. All rights reserved.
//

#import "ViewController.h"
#import "SJplayView.h"

@interface ViewController ()
{
    CADisplayLink * _link;
}


@property (nonatomic ,weak) SJplayView * playerView;
@property (nonatomic ,strong) AVPlayerItem *playerItem;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallBack:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [_link setPaused:YES];
    
    [self loadItem];
}

- (void)setupUI
{
    SJplayView * playerView = [[SJplayView alloc] init];
    [self.view addSubview:playerView];
    self.playerView = playerView;
    self.playerView.frame = CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 200);
    self.playerView.backgroundColor = [UIColor redColor];
}

- (void)loadItem
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
    assert(item);
    self.playerItem = item;
    AVPlayerLayer *layer = (AVPlayerLayer *)self.playerView.layer;
    AVPlayer *plaer = [[AVPlayer alloc] initWithPlayerItem:item];
    [layer setPlayer:plaer];
    [plaer play];
}

- (void)displayLinkCallBack:(CADisplayLink *)link
{
    NSLog(@"diplayer link call back");
}

@end
