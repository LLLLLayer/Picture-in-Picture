//
//  PIPStandardPlayerViewController.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/13.
//

#import "PIPResourcesManager.h"
#import "PIPActivePlayerViewControllerStorage.h"
#import "PIPStandardPlayerViewController.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PIPStandardPlayerViewController () <AVPlayerViewControllerDelegate>

@property (nonatomic, strong) AVPlayerViewController *playViewController;

@end

@implementation PIPStandardPlayerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.playViewController];
    [self.playViewController didMoveToParentViewController:self];
    
    [self.view addSubview:self.playViewController.view];
    self.playViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.playViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.playViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.playViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.playViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
    
    self.playViewController.player = [AVPlayer playerWithURL:[PIPResourcesManager videoUrl]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.playViewController.player play];
}

#pragma mark - Getter

- (AVPlayerViewController *)playViewController {
    if (!_playViewController) {
        _playViewController = [[AVPlayerViewController alloc] init];
        // The default value is YES
        _playViewController.allowsPictureInPicturePlayback = YES;
        // The default value is NO
        _playViewController.canStartPictureInPictureAutomaticallyFromInline = YES;
        _playViewController.delegate = self;
    }
    return _playViewController;
}

#pragma mark - AVPlayerViewControllerDelegate

- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    [[PIPActivePlayerViewControllerStorage sharedInstance] storePlayerViewController:self];
}

- (void)playerViewControllerDidStartPictureInPicture:(AVPlayerViewController *)playerViewController {
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error {
    [[PIPActivePlayerViewControllerStorage sharedInstance] removePlayerViewController:self];
}

- (void)playerViewControllerWillStopPictureInPicture:(AVPlayerViewController *)playerViewController {
}

- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController {
    [[PIPActivePlayerViewControllerStorage sharedInstance] removePlayerViewController:self];
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    [self.delegate restorePlayerViewController:self withCompletionHandler:completionHandler];
}

- (BOOL)playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart:(AVPlayerViewController *)playerViewController {
    return YES;
}

@end
