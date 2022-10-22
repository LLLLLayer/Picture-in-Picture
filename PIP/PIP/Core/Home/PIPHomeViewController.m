//
//  PIPHomeViewController.m
//  PIP
//
//  Created by yangjie.layer on 2022/10/13.
//

#import "PIPPlayerViewControllerDelegate.h"
#import "PIPHomeViewController.h"
#import "PIPStandardPlayerViewController.h"
#import "PIPCustomPlayerViewController.h"

#import <AVKit/AVKit.h>

@interface PIPHomeViewController () <UITableViewDelegate, UITableViewDataSource, PIPPlayerViewControllerDelegate>

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSArray<NSString *> *rows;

@end

@implementation PIPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupUI];
}

- (void)__setupUI {
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];
}

#pragma mark - Getter / Setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSArray<NSString *> *)rows {
    if (!_rows) {
        _rows = @[
        @"Standard player",
        @"Custom player",
        @"Custom player & SampleBuffer",
        @"Custom player & SampleBuffer & Images",
        @"Custom player & Private Api"
        ];
    }
    return _rows;
}

#pragma mark - Config

- (void)__updateAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *categoryError = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback
                         mode:AVAudioSessionModeMoviePlayback
                      options:AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption error:&categoryError];
    if (categoryError) {
        NSLog(@"Set audio session category error: %@", categoryError.localizedDescription);
    }
    NSError *activeError = nil;
    [audioSession setActive:YES error:&activeError];
    if (activeError) {
        NSLog(@"Set audio session active error: %@", activeError.localizedDescription);
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell.textLabel setText:self.rows[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 系统播放器
    if ([self.rows[indexPath.row] isEqualToString:@"Standard player"]) {
        PIPStandardPlayerViewController *playerViewController = [[PIPStandardPlayerViewController alloc] init];
        playerViewController.delegate = self;
        [self.navigationController pushViewController:playerViewController animated:YES];
        [self __updateAudioSession];
        return;
    }
    
    // 自定义播放器
    PIPCustomPlayerViewController *playerViewController = [[PIPCustomPlayerViewController alloc] init];
    playerViewController.delegate = self;
    if ([self.rows[indexPath.row] isEqualToString:@"Custom player"]) {
        playerViewController.type = PIPCustomPlayerViewTypeNormal;
    } else if ([self.rows[indexPath.row] isEqualToString:@"Custom player & SampleBuffer"]) {
        playerViewController.type = PIPCustomPlayerViewTypeSampleBuffer;
    } else if ([self.rows[indexPath.row] isEqualToString:@"Custom player & SampleBuffer & Images"]) {
        playerViewController.type = PIPCustomPlayerViewTypeImageSampleBuffer;
    } else if ([self.rows[indexPath.row] isEqualToString:@"Custom player & Private Api"]) {
        playerViewController.type = PIPCustomPlayerViewTypePrivateApi;
    }
    
    [self __updateAudioSession];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

#pragma mark - PIPPlayerViewControllerDelegate

- (void)restorePlayerViewController:(UIViewController *)viewController
              withCompletionHandler:(void (^)(BOOL restored))completionHandler {
    if ([self __topViewController] != viewController) {
        [self.navigationController pushViewController:viewController animated:NO];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completionHandler(YES);
    });
}

- (UIViewController *)__topViewController {
    __block UIViewController *topViewController = self;
    [UIApplication.sharedApplication.connectedScenes enumerateObjectsUsingBlock:^(UIScene * _Nonnull scene, BOOL * _Nonnull stop) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if ([window isKeyWindow]) {
                    topViewController = window.rootViewController;
                    if ([topViewController isKindOfClass:[UINavigationController class]]) {
                        topViewController = ((UINavigationController *)topViewController).topViewController;
                    }
                    *stop = YES;
                }
            }
        }
    }];
    return topViewController;
}

@end
