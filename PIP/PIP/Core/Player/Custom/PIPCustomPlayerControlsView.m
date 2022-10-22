//
//  PIPCustomPlayerControlsView.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/14.
//

#import "PIPCustomPlayerControlsView.h"

@interface PIPCustomPlayerControlsView ()

@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UIButton *pipButton;
@property(nonatomic, strong) UIProgressView *progressView;

@end

@implementation PIPCustomPlayerControlsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __setupUI];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isPlaying"]) {
        [self __updatePlayButtonWithPlayStates:self.delegate.isPlaying];
    }
}

- (void)updatePipEnable:(BOOL)enable {
    self.pipButton.enabled = enable;
}

- (void)updateProgress:(float)progress {
    self.progressView.progress = progress;
}

#pragma mark - UI

- (void)__setupUI {
    self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    self.layer.cornerRadius = 8.0;
    
    [self addSubview:self.playButton];
    [self __updatePlayButtonWithPlayStates:YES];
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.playButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.playButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.playButton.widthAnchor constraintEqualToConstant:25.0],
        [self.playButton.heightAnchor constraintEqualToConstant:20.0],
    ]];
    
    [self addSubview:self.pipButton];
    self.pipButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.pipButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.pipButton.leadingAnchor constraintEqualToAnchor:self.playButton.trailingAnchor constant:8.0],
        [self.pipButton.widthAnchor constraintEqualToConstant:25.0],
        [self.pipButton.heightAnchor constraintEqualToConstant:20.0],
    ]];
    
    [self addSubview:self.progressView];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.progressView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.progressView.leadingAnchor constraintEqualToAnchor:self.pipButton.trailingAnchor constant:8.0],
        [self.progressView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],
        [self.progressView.heightAnchor constraintEqualToConstant:10.0],
    ]];
}

- (void)__updatePlayButtonWithPlayStates:(BOOL)isPlaying {
    UIImage *image = [UIImage systemImageNamed:!isPlaying ? @"play.fill" : @"pause.fill"];
    [self.playButton setImage:image forState:UIControlStateNormal];
}

#pragma mark - Setter/Getter

- (void)setDelegate:(id<PIPCustomPlayerControlsViewDelegate>)delegate {
    if (_delegate) { [self removeObserver:(NSObject *)_delegate forKeyPath:@"isPlaying"]; }
    if (delegate) { [(NSObject *)delegate addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil]; }
    _delegate = delegate;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.tintColor = [UIColor whiteColor];
        [_playButton addTarget:self action:@selector(__handlePlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)pipButton {
    if (!_pipButton) {
        _pipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _pipButton.tintColor = [UIColor whiteColor];
        [_pipButton setImage:[UIImage systemImageNamed:@"pip.enter"] forState:UIControlStateNormal];
        [_pipButton addTarget:self action:@selector(__handlePipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pipButton;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressViewStyle = UIProgressViewStyleDefault;
        _progressView.progressTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _progressView.trackTintColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    }
    return _progressView;
}

#pragma mark - Action

- (void)__handlePlayButtonTapped:(UIButton *)button {
    BOOL isPlaying = !([self.delegate respondsToSelector:@selector(isPlaying)] && [self.delegate isPlaying]);
    if ([self.delegate respondsToSelector:@selector(controlsView:updatePlayStatus:)]) {
        [self.delegate controlsView:self updatePlayStatus:isPlaying];
    }
}

- (void)__handlePipButtonTapped:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(enterPipWithControlsView:)]) {
        [self.delegate enterPipWithControlsView:self];
    }
}

@end
