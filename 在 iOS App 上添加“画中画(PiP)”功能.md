
# PiP 基础

## 配置 iOS App

### 配置 Audio Session

大多数 iOS 的媒体播放 App 都需要额外配置才能启用所需的播放行为。Audio Session  充当 App 和操作系统的中介，进而充当底层音频硬件。我们使用  Audio Session 向操作系统传达 App 音频的性质，而无需详细说明特定的行为或与音频硬件所需的交互。将这些细节的管理会委托给 Audio Session，确保操作系统能够最好地管理用户的音频体验。

所有 iOS App 都有一个默认  Audio Session，预配置的表现如下：

- 当我们的 App 播放音频时，它会使任何其他后台音频静音。

- 锁定设备或者打开静音模式，会使我们的 App 音频静音。
- 支持我们的 App 进行音频播放，但不允许进行录音。



默认 Audio Session 并不适合所有的媒体播放 App。我们需要配置 App 的 [Audio Session Category](https://developer.apple.com/documentation/avfaudio/avaudiosession/category)，AVFoundation 定义了几个我们可以使用的 Category：

| [AVAudioSessionCategory](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategory?language=objc) |                  Category 特征                   |   Category 能力    | 屏幕锁定或静音开关打开 | 是否打断不支持混音的 App 的播放 |                             示例                             |
| :----------------------------------------------------------: | :----------------------------------------------: | :----------------: | :--------------------: | :-----------------------------: | :----------------------------------------------------------: |
| [`AVAudioSessionCategoryAmbient`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryambient?language=objc) | 当前 App 的播放声音可以和其他app播放的声音共存。 |    用于播放音频    |       音频被静音       |            不会打断             |  用于“伴奏” App，用户在其他 App 播放音乐时弹奏的虚拟钢琴。   |
| [`AVAudioSessionCategoryMultiRoute`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategorymultiroute?language=objc) |         允许多条音频流的同步输入和输出。         | 用于录制和播放音频 |       音频被静音       |             会打断              | App 可以将一条音频流发送到用户的耳麦，将另一条音频流发送发送到 HDMI 路径。 |
| [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc) |            在录音的同时播放其他声音。            | 用于录制和播放音频 |        继续播放        |        会打断，但可修改         |                       用于 VoIP App。                        |
| [`AVAudioSessionCategoryPlayback`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayback?language=objc) |            播放音频对 App 至关重要。             |    用于播放音频    |        继续播放        |        会打断，但可修改         |                     用于音乐流媒体 App。                     |
| [`AVAudioSessionCategoryRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryrecord?language=objc) |           录制音频同时使播放音频静音。           |   用于录制和音频   |     锁屏时继续录制     |             会打断              |                     用于录制音频的 App。                     |
| [`AVAudioSessionCategorySoloAmbient`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategorysoloambient?language=objc) |                 默认的播放音频。                 |    用于播放音频    |       音频被静音       |             会打断              |                     用于视频流媒体 App。                     |



Category 为我们的 App 设置了基本行为，使用 [Audio Session Mode](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategory?language=objc) 将专门的行为分配再分配给 Category：

| [AVAudioSessionMode](https://developer.apple.com/documentation/avfaudio/avaudiosessionmode?language=objc) |                          Mode 特征                           |                        Mode 共用场景                         |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| [`AVAudioSessionModeDefault`](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodedefault?language=objc) |                        默认 的 Mode。                        |                  可以用于每个音频会话类别。                  |
| [`AVAudioSessionModeGameChat`](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodegamechat?language=objc) |        使用 GameKit 语音聊天服务的 App 设置的 Mode。         | 仅对 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc) Categoriy 生效。 |
| [`AVAudioSessionModeMeasurement`](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodemeasurement?language=objc) |           表明 App 正在执行音频输入或输出的测量。            | 用于需要最大限度地减少系统提供的对输入和输出信号的信号处理量的 App。用于 [`AVAudioSessionCategoryPlayback`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayback?language=objc)、 [`AVAudioSessionCategoryRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryrecord?language=objc)、[`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc) Categoriy。 |
| [`AVAudioSessionModeMoviePlayback`](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodemovieplayback?language=objc) |              表示 App 正在播放电影内容的 Mode。              | 使用信号处理来增强某些音频路径的电影播放，例如内置扬声器或耳机。仅于[`AVAudioSessionCategoryPlayback`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayback?language=objc) Categoriy 一起使用。 |
| [`AVAudioSessionModeSpokenAudio`](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodespokenaudio?language=objc) | 用于连续语音的 Mode，在另一个 App 播放简短的音频提示时可以暂停音频。 | 用于播放连续语音的 App，例如有声读物。如果另一个 App 播放语音提示，App 暂停自身音频。导致中断的 App 的音频结束后，可以恢复 App 的音频播放。 |
| [`AVAudioSessionModeVideoChat`](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodevideochat?language=objc) |               表明 App 正在参与在线视频会议。                | 用于视频聊天 App，会优化设备的语音音调均衡，用于 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc) 或 [`AVAudioSessionCategoryRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryrecord?language=objc) Categoriy。 |
| [`AVAudioSessionModeVideoRecording`](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodevideorecording?language=objc) |                   表示 App 正在录制电影。                    | 确保系统提供适当的音频信号处理，例如在具有多个内置麦克风的设备上，音频会话使用离摄像机最近的麦克风。用于  [`AVAudioSessionCategoryRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryrecord?language=objc) 或 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc) Categoriy。 |
| [`AVAudioSessionModeVoiceChat`](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodevoicechat?language=objc) |        表明 App 正在执行双向语音通信，例如使用 VoIP。        | 优化设备的语音音调均衡，用于 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc) Categoriy。 |
| [`AVAudioSessionModeVoicePrompt`](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodevoiceprompt?language=objc) |                 App 使用文本转语音播放音频。                 | App 连接到某些音频设备时，允许不同的路由行为。例如向用户播放简短提示的导航 App。 |



有时在定制我们的 Category 时，除了这些 Mode 外，我们还需要使用到一些 Option：

| [AVAudioSessionCategoryOptions](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions?language=objc) | Option 特征                                                  |                       Option 共用场景                        |
| :----------------------------------------------------------: | ------------------------------------------------------------ | :----------------------------------------------------------: |
| [`AVAudioSessionCategoryOptionMixWithOthers`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionmixwithothers?language=objc) | 是否与来自其他音频 App 中的音频混合。设置后 App 会将其音频与后台 App 中播放的音频混合，清除此 Option 会中断其他 Audio Session。 | 可以与 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc)、 [`AVAudioSessionCategoryPlayback`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayback?language=objc) 和 [`AVAudioSessionCategoryMultiRoute`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategorymultiroute?language=objc) 一起使用。如果使用 [`AVAudioSessionCategoryAmbient`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryambient?language=objc) Category，会自动设置此 Option。设置 [`AVAudioSessionCategoryOptionDuckOthers`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionduckothers?language=objc) 或 [`AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptioninterruptspokenaudioandmixwithothers?language=objc) 会默认设置该 Option。 |
| [`AVAudioSessionCategoryOptionDuckOthers`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionduckothers?language=objc) | 播放音频时降低其他 Audio Session 音量。App 的音频与其他 App 的音频混合。但是当我们 App 播放其音频时，系统会降低其他 Audio Session 的音量以我们的 App 更加突出。清除此 Option 会中断其他 Audio Session。 | 可以与 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc)、 [`AVAudioSessionCategoryPlayback`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayback?language=objc)、 [`AVAudioSessionCategoryMultiRoute`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategorymultiroute?language=objc)一起使用。 |
| [`AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptioninterruptspokenaudioandmixwithothers?language=objc) | 播放其音频时是否暂停来自其他 Audio Session 的语音音频内容。系统会将 App 的音频与其他音频会话混合，但会中断使用  [`AVAudioSessionModeSpokenAudio `](https://developer.apple.com/documentation/avfaudio/avaudiosessionmodespokenaudio?language=objc) Mode 的 Audio Session。在 App 的 Audio Session 停用后，系统会恢复中断的应用程序的音频。 | 可以与 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc)、[`AVAudioSessionCategoryPlayback`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayback?language=objc)、 [`AVAudioSessionCategoryMultiRoute`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategorymultiroute?language=objc) 一起使用。设置该 Option 会隐式设置 [`AVAudioSessionCategoryOptionMixWithOthers`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionmixwithothers?language=objc)。当 App 使用此 Option 配置时，请在停用 Session 时通知系统上的其他 App，以便它们可以恢复音频播放，使用 [`AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation `](https://developer.apple.com/documentation/avfaudio/avaudiosessionsetactiveoptions/avaudiosessionsetactiveoptionnotifyothersondeactivation?language=objc) 停用 Audio Session。 |
| [`AVAudioSessionCategoryOptionAllowBluetooth`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionallowbluetooth?language=objc) | 确定蓝牙免提设备是否为可用的输入路径。设置此 Option 以允许将音频输入和输出路由到配对的蓝牙免提配置文件 (HFP) 设备。如果清除此 Option，配对的蓝牙 HFP 设备不会显示为可用的音频输入路由。 | 与 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc) 或 [`AVAudioSessionCategoryRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryrecord?language=objc) 一起使用。 |
| [`AVAudioSessionCategoryOptionAllowBluetoothA2DP`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionallowbluetootha2dp?language=objc) | 确定是否可以将此会话中的音频流式传输到支持高级音频分发配置文件 (A2DP) 的蓝牙设备。 | A2DP 是一种仅用于输出的立体声配置文件，适用于更高带宽的音频用例，例如音乐播放。如果 Catrgory 为  [`AVAudioSessionCategoryAmbient`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryambient?language=objc)、[`AVAudioSessionCategorySoloAmbient`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategorysoloambient?language=objc)、 [`AVAudioSessionCategoryPlayback`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayback?language=objc)，系统会自动路由到A2DP端口。 |
| [`AVAudioSessionCategoryOptionAllowAirPlay`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionallowairplay?language=objc) | 确定是否可以将此 Session 中的音频流式传输到 AirPlay 设备。   | 对于 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc) Catrgory 只能显式设置此选项，对于大多数其他 Catagory，系统会隐式设置此 Option。对于 [`AVAudioSessionCategoryMultiRoute`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategorymultiroute?language=objc) 或者 [`AVAudioSessionCategoryRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryrecord?language=objc) 会隐式清除此 Option。 |
| [`AVAudioSessionCategoryOptionDefaultToSpeaker`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptiondefaulttospeaker?language=objc) | 确定音频是否默认为内置扬声器而不是接收器。                   | 只有在使用 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc) Category 时才能设置此 Option。它用于修改路由行为，以便在没有使用其他配件（例如耳机）时，音频始终路由到扬声器而不是接收器。 |
| [`AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionoverridemutedmicrophoneinterruption?language=objc) | 指示系统在使内置麦克风静音时是否中断 Audio Session。某些设备包含隐私功能，可在特定条件下在硬件级别使内置麦克风静音。发生这种情况时，系统会中断从麦克风捕获输入的 Audio Session。在系统将麦克风静音后尝试开始音频输入会导致错误。 | 如果您的应用使用支持输入和输出的 Category，例如 [`AVAudioSessionCategoryPlayAndRecord`](https://developer.apple.com/documentation/avfaudio/avaudiosessioncategoryplayandrecord?language=objc)，可以设置此 Option 以禁用默认行为并继续使用 Session。 |

> 我们可以在设置 Category 后随时使用 `setActive:withOptions:error:` 激活 Audio Session，但通常最好推迟此调用到 App 开始音频播放，确保不会过早中断可能正在进行的其他后台音频。



### 启用 Background Audio

iOS App 要求我们为 App 的后台操作，启用某些功能。媒体播放 App 需要的一个常见功能是播放后台音频(Background Audio)。启用此功能后，当用户切换到另一个 App 或锁定 iOS 设备时，我们的 App 的音频会继续播放。在 iOS 中启用 AirPlay 和 PiP 播放等高级播放功能也需要此功能。

配置这些功能的最简单方法是使用 Xcode。在 Xcode 中选择 App 的 Target，然后选择 Signing & Capabilities，在 Capabilities 下，添加“Background Modes”功能，然后在其列表下选择“Audio, AirPlay, and Picture in Picture”选项。启用此模式并配置 Audio Session 后，我们的 Audio Session 就可以播放后台音频了。

![output](./在 iOS App 上添加“画中画(PiP)”功能.assets/output.png)



## 标准播放器中的 PiP

[`AVPlayerViewController`](https://developer.apple.com/documentation/avkit/avplayerviewcontroller?language=objc) 提供跨 iOS、iPadOS 和 tvOS 的标准视频播放体验。配置 iOS App 的音频播放后，`AVPlayerViewController` 标准播放器将自动支持 PiP 播放。当 App 在受支持的设备上运行时，用户可以在标准播放器中管理 PiP。

当用户在标准播放器界面中选择 PiP 时，PiP 播放开始。使用 [`allowsPictureInPicturePlayback`](https://developer.apple.com/documentation/avkit/avplayerviewcontroller/1615821-allowspictureinpictureplayback?language=objc) 指示播放器是否允许 PiP 播放。

> `allowsPictureInPicturePlayback` 支持 iOS9.0+，即 PiP 功能最低系统版本为 iOS9.0。

在 iOS 和 iPadOS 中，如果视频以全屏模式播放并且用户退出 App，PiP 会自动开始播放。 若视频的宽度没有填满整个屏幕时，使用 [`canStartPictureInPictureAutomaticallyFromInline` ](https://developer.apple.com/documentation/avkit/avplayerviewcontroller/3689455-canstartpictureinpictureautomati?language=objc) 来指示视频是主要焦点。 

> 在 iOS 和 iPadOS 中，用户可以在“设置”>“通用”>“画中画”中禁用 PiP 的自动调用。

在 PiP界面中选择停止按钮会终止画中画并在我们的 App 中恢复视频播放。 AVKit 无法假设我们如何设计 App，它不知道如何正确恢复 App 的视频播放界面。 相反，它将责任委托给我们。

要处理恢复过程，代码必须遵守 [`AVPlayerViewControllerDelegate`](https://developer.apple.com/documentation/avkit/avplayerviewcontrollerdelegate?language=objc) 协议并实现 [`playerViewController:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:`](https://developer.apple.com/documentation/avkit/avplayerviewcontrollerdelegate/1615838-playerviewcontroller?language=objc) 方法，以 Swift 代码为例：

```swift
func playerViewController(
_ playerViewController: AVPlayerViewController,
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
    present(playerViewController, animated: false) {
        completionHandler(true)
    }
}
```

> 避免在期间添加不必要的动画，确保用户快速恢复的体验。

从 iOS14.0 开始，用户的 PiP 界面提供了允许用户在视频中快进和后退的控件。系统默认为 iOS14.0 及更高版本的 App 启用这些控件。如果我们需要限制跳过法律免责声明或广告的内容，请在视频的播放对应内容时将  [`requiresLinearPlayback`](https://developer.apple.com/documentation/avkit/avplayerviewcontroller/1627633-requireslinearplayback?language=objc) 设置为 `YES`。 当允许用户使用快进和后退的控件时，再将此属性设置回 `NO`。



## 自定义播放器中的 PiP

使用 AVKit 框架的 [`AVPictureInPictureController`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller?language=objc) 类，将 PiP 添加到自定义的播放器中。此类允许我们在自定义播放器中实现与 `AVPlayerViewController` 中相同的 PiP 行为。

### 更新自定义播放器用户界面

我们首先需要将 UI 添加到自定义播放器界面中，使用户能够开始 PiP 播放。 使用 `AVPictureInPictureController` 的 [`pictureInPictureButtonStartImage`](](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller/3172686-pictureinpicturebuttonstartimage?language=objc)) 和 [`pictureInPictureButtonStopImage`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller/3172687-pictureinpicturebuttonstopimage) 类属性访问用于控制 PiP 播放的标准图像。以 Swift 代码为例：

```Swift
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *startImage = [AVPictureInPictureController pictureInPictureButtonStartImage];
    UIImage *stopImage = [AVPictureInPictureController pictureInPictureButtonStopImage];
    self.pipButton setImage:startImage forState:UIControlStateNormal];
    self.pipButton setImage:stopImage forState:UIControlStateSelected];
}
```

> 可以 KVO 在 controller 的 [`canStopPictureInPicture`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller/3633721-canstoppictureinpicture?language=objc) 属性，来显示适当的 UI。其指示 PiP 是否处于活动状态并且能够停止。当值为`YES` 时，调用 `stopPictureInPicture` 将停止运行中的 PiP。



### 创建 AVPictureInPictureController

创建一个 [`AVPictureInPictureController`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller) 实例来控制 App 中的 PiP 播放。在尝试创建 `pipCpmtroller` 实例之前，先通过调用 [`isPictureInPictureSupported`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller/1614693-ispictureinpicturesupported?language=objc) 方法验证当前设备是否支持 PiP 播放。以 Swift 代码为例：

```Swift
var pipController: AVPictureInPictureController!
var pipPossibleObservation: NSKeyValueObservation?

func setupPictureInPicture() {
    // Ensure PiP is supported by current device.
    if AVPictureInPictureController.isPictureInPictureSupported() {
        // Create a new controller, passing the reference to the AVPlayerLayer.        
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController.delegate = self
        pipPossibleObservation = 
      pipController.observe(
        \AVPictureInPictureController.isPictureInPicturePossible,
        options: [.initial, .new]) { [weak self] _, change in
        // Update the PiP button's enabled state.            
            self?.pipButton.isEnabled = change.newValue ?? false
        }
    } else {
    // PiP isn't supported by the current device. Disable the PiP button.        
    pipButton.isEnabled = false    
    }
}
```

> 模拟器不支持 PiP 播放。

上述示例创建一个新的 `AVPictureInPictureController` 实例，向其传递  `AVPlayerLayer`  呈现视频内容。系统支持在 PiP 窗口中显示来自 [`AVPlayerLayer`](https://developer.apple.com/documentation/avfoundation/avplayerlayer?language=objc) 或 [`AVSampleBufferDisplayLayer`](https://developer.apple.com/documentation/avfoundation/avsamplebufferdisplaylayer?language=objc) 的内容。要使 PiP 功能正常工作，需要保持对 `pipController` 的强引用。

> PiP 显示不使用我们传递给 `AVPictureInPictureController` 的 `AVPlayerLayer`，因此当 PiP 处于活动状态时，AVFoundation 停止向 AVPlayerLayer 提供视频帧。

要参与 PiP 的生命周期，我们的代码应遵守 `AVPictureInPictureControllerDelegate` 协议，并设置为 `pipController` 的 `delegate`。 

此外，KVO `pipController` 的 [`pictureInPicturePossible`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller/1614691-pictureinpicturepossible?language=objc) 属性，来观察在当前上下文中是否可以使用 PiP，例如当系统显示活动的 FaceTime 窗口时无法使用 PiP。通过观察此属性，我们可以确定何时适合更改 PiP 按钮的启用状态。



### 发布 Now Playing State

系统会决定显示“正在播放”信息，即使 App 的 UI 未显示 Session 相关的内容，系统也可能随时显示我们的 App 的 Session。有关 Now Playing 元数据的详细信息，可以参考 [`MPNowPlayingInfoCenter`](https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter?language=objc) 上的 [Now Playing Metadata Properties](https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter?language=objc#1674387) 主题。以 Swift 代码为例：

```Swift
func publishNowPlayingMetadata() {
    nowPlayingSession.nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    nowPlayingSession.becomeActiveIfPossible()
}
```



### 处理用户发起的请求

完成 `AVPictureInPictureController` 设置后，添加一个方法来处理用户发起的请求，以开始或停止 PiP 播放。以 Swift 代码为例：

```Swift
@IBAction func togglePictureInPictureMode(_ sender: UIButton) {
    if pipController.isPictureInPictureActive {
        pipController.stopPictureInPicture()
    } else {
        pipController.startPictureInPicture()
    }
}
```

> 仅能通过用户交互开始 PiP 播放，而不以编程方式打开。否则 App Store 审核团队会拒审。



### 恢复对 App 的控制

用户在 PiP 窗口中选择停止 PiP ，系统会将控制权返回给 App。默认情况下，当控制权返回到 App 时会终止播放，正确的恢复视频播放界面是我们要做的。

要处理恢复过程，请实现委托方法  [`pictureInPictureController:restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontrollerdelegate/1614703-pictureinpicturecontroller?language=objc)  并根据需要恢复播放器界面。恢复完成后，调用值为 `YES` 的完成处理程序。以 Swift 代码为例：

```Swift
func pictureInPictureController(
_ pictureInPictureController: AVPictureInPictureController,
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
) {    
    // Restore the user interface.    
    completionHandler(true)
}
```



### 隐藏播放控件

当 PiP 处于活动状态时，隐藏主播放器中的播放控件，并在 PiP 窗口中显示内容以表明 PiP 模式处于活动状态。请使用 [`pictureInPictureControllerWillStartPictureInPicture:`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontrollerdelegate/1614711-pictureinpicturecontrollerwillst?language=objc) 和 [`pictureInPictureControllerDidStopPictureInPicture:`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontrollerdelegate/1614717-pictureinpicturecontrollerdidsto?language=objc) 委托方法，并采取所需的操作。以 Swift 代码为例：

```Swift
 func pictureInPictureControllerWillStartPictureInPicture(
 _ pictureInPictureController: AVPictureInPictureController
 ) {
     // Hide the playback controls.    
     // Show the placeholder artwork.
 }
 
func pictureInPictureControllerDidStopPictureInPicture(
_ pictureInPictureController: AVPictureInPictureController
) {
    // Hide the placeholder artwork.    
    // Show the playback controls.
}
```





## 使用 PiP 进行视频通话

在视频通话 App 中使用 PiP，以便用户可以在视频通话时与其他 App 一起执行多项任务。在 iOS15.0 及更高版本中，AVKit 为视频通话 App 提供 PiP 支持，这使我们能够提供类似于 FaceTime 的视频通话体验。

> 在 iOS 16 及更高版本中，我们通过启用 AVCaptureSession 的 [`multitaskingCameraAccessEnabled`](https://developer.apple.com/documentation/avfoundation/avcapturesession/4013227-multitaskingcameraaccessenabled?language=objc) 属性在 PiP 下使用相机。部署目标早于 iOS 16 的应用需要 [com.apple.developer.avfoundation.multitasking-camera-access](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_avfoundation_multitasking-camera-access?language=objc) 授权才能在 PiP 下使用摄像头。



### 创建 sourceView

提供 PiP 支持首先选择要在 `videoCallController` 中显示的 `sourceView`。我们需要将 `UIView` 添加到 [`AVPictureInPictureVideoCallViewController`](https://developer.apple.com/documentation/avkit/avpictureinpicturevideocallviewcontroller)，因此根据需要使用 [`AVCaptureVideoPreviewLayer`](https://developer.apple.com/documentation/avfoundation/avcapturevideopreviewlayer?language=objc) 或 [`AVSampleBufferDisplayLayer`](https://developer.apple.com/documentation/avfoundation/avsamplebufferdisplaylayer?language=objc)，不支持 `MTKView`。 视频通话应用需要显示远程视图，所以使用 `AVSampleBufferDisplayLayer` 来实现。以 Swift 代码为例：

```Swift
class SampleBufferVideoCallView: UIView {
    override class var layerClass: AnyClass {
        AVSampleBufferDisplayLayer.self
    }
    var sampleBufferDisplayLayer: AVSampleBufferDisplayLayer {
    layer as! AVSampleBufferDisplayLayer
    }
}
```



### 创建 videoCallController

要显示我们的 `sourceView`，需要创建一个 `AVPictureInPictureVideoCallViewController` 并将 `sourceView` 添加为子视图。以 Swift 代码为例：

```Swift
let pipVideoCallViewController = AVPictureInPictureVideoCallViewController()
pipVideoCallViewController.preferredContentSize = CGSize(width: 1080, height: 1920)
pipVideoCallViewController.view.addSubview(sampleBufferVideoCallView)
```

> 也需要使用 `isPictureInPictureSupported` 判断当前设备是否支持 PiP 播放。如果当前设备不支持 PiP，尝试初始化 PiP 控制器将返回 nil。



### 使用 contentSource 创建 一个 pipController

在创建 `AVPictureInPictureController` 之前，我们需要创建一个 [`AVPictureInPictureControllerContentSource`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontrollercontentsource?language=objc) 来表示系统显示的内容的来源。`contentSource` 需要一个`AVPictureInPictureVideoCallViewController`，以及一个包含与视频通话相关联的内容的 `sourceView`。以 Swift 代码为例：

```Swift
let pipContentSource = AVPictureInPictureController.ContentSource(
                          activeVideoCallSourceView: videoCallViewSourceView,
                          contentViewController: pipVideoCallViewController)
```

> 在呼叫结束时，将 `pipController` 上的 `contentSource` 设置为 `nil` 或释放 `pipController` 来避免意外启动 PiP。

创建  `pipContentSource` 后，使用它来初始化 `AVPictureInPictureController`。 默认情况下，如果 sourcVview 是全屏的，或者我们将 [`canStartPictureInPictureAutomaticallyFromInline`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller/3689454-canstartpictureinpictureautomati?language=objc) 设置为 `YES`，则当用户移动到后台时，PiP 开始。 如果我们 App 在前台，可以通过调用 [`startPictureInPicture`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller/1614687-startpictureinpicture?language=objc) 来启动 PiP。以 Swift 代码为例：

```Swift
let pipController = AVPictureInPictureController(contentSource: pipContentSource)
pipController.canStartPictureInPictureAutomaticallyFromInline = true
pipController.delegate = self
```

系统使用 `sourceView` 来确定 PiP 动画的源帧，以及用户返回 App 或 PiP 停止时的恢复目标。

> 当我们使用 `AVPictureInPictureVideoCallViewController` 时，PiP 窗口不接收触摸事件，因此我们无法通过添加按钮来自定义窗口的用户界面。



### 观察 PiP 生命周期事件

当我们使用 PiP 时，通过 [`AVPictureInPictureControllerDelegate`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontrollerdelegate?language=objc) 来响应生命周期事件。 这使我们可以根据 PiP 状态处理应用程序的用户界面。

当系统或用户隐藏 PiP 时，系统会中断我们的 Capture Session，因此观察 [`AVCaptureSessionWasInterruptedNotification`](https://developer.apple.com/documentation/avfoundation/avcapturesessionwasinterruptednotification?language=objc) 的 [`AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableInBackground`](https://developer.apple.com/documentation/avfoundation/avcapturesessioninterruptionreason/avcapturesessioninterruptionreasonvideodevicenotavailableinbackground?language=objc) 的来处理中断。

当我们的 App 处于 PiP 时，它无法控制相机。例如，Camera.app 在打开时会承担对相机的控制权，并且在 Camera.app 完成后系统会返回相机控制权。 我们观察 [`AVCaptureSessionWasInterruptedNotification`](https://developer.apple.com/documentation/avfoundation/avcapturesessionwasinterruptednotification?language=objc) 的 [`AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient`](https://developer.apple.com/documentation/avfoundation/avcapturesessioninterruptionreason/avcapturesessioninterruptionreasonvideodeviceinusebyanotherclient?language=objc) 来处理中断。



# PiP 实践

以 OC 实现的 PIP 项目为例，文章省略了部分与主题无关的内容，详细实现请参考项目源码。

App 将从 `PIPHomeViewController` 展示不同入口，进入标准播放器中的 PiP 或以多种方案实现的自定义播放器中的 PiP。

![UML 图](./在 iOS App 上添加“画中画(PiP)”功能.assets/UML 图.jpeg)



## 配置 iOS App 的音频播放

在 `PIPHomeViewController` 新增以下代码，在后续展示标准播放器中的 PiP、自定义播放器中的 PiP 时，将调用使用该配置：

```Objective-C
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
```

这里没有放在 `application:didFinishLaunchingWithOptions:`，是 Demo App 后续为了进行可能的 Category 切换时，可以便捷的在 `PIPHomeViewController` 中处理。



## 标准播放器中的 PiP

### 辅助工具或服务

#### PIPActivePlayerViewControllerStorage

不论是标准播放器中的 PiP，还是自定义播放器中的 PiP，我们都允许当前用户切换 PiP 模式后，App 在前台的情况下，进行其他操作。当用户点击 PiP 恢复时，我们需要负责手动将对应的播放器 `viewController` 放入导航栈。否则 PiP 将无法正常恢复。

因此我们需要一个存储服务，将这些播放器 `viewController`，会在 PiP 开始和结束时进行存储和移除：

```Objective-C
@interface PIPActivePlayerViewControllerStorage : NSObject
 
+ (instancetype)sharedInstance;
 
- (void)storePlayerViewController:(UIViewController *)viewController;
 
- (void)removePlayerViewController:(UIViewController *)viewController;
 
@end
```



#### PIPPlayerViewControllerDelegate

同上一部分，PiP 恢复时，谁来操作导航栈？我们将这部分逻辑委托给 `PIPHomeViewController` 进行处理，它在构造标准播放器或自定义播放器时，会将其遵循 `PIPPlayerViewControllerDelegate` 协议的 `delegate` 设置为自己，当播放器回调恢复时间时，进行导航栈操作：

```Objective-C
- (void)restorePlayerViewController:(UIViewController *)viewController
              withCompletionHandler:(void (^)(BOOL restored))completionHandler {
    if ([self __topViewController] != viewController) {
        [self.navigationController pushViewController:viewController animated:NO];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completionHandler(YES);
    });
}
```





### 标准播放器 PIPStandardPlayerViewController

![Standard player](./在 iOS App 上添加“画中画(PiP)”功能.assets/Standard player.gif)

`PIPStandardPlayerViewController` 只有一个属性，它将完成我们的所有工作：

```Objective-C
@property (nonatomic, strong) AVPlayerViewController *playViewController;
```



标准播放器的内容很简单，我们来依次查看：

```Objective-C
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
```

上述代码中，我们进行了以下工作：

- `viewDidLoad` 方法中：
  - 将 `playViewController` 添加为 `PIPStandardPlayerViewController` 的 `childViewController`；
  - 对 `playViewController` 的 `view` 进行布局；
  - 将 `playViewController` 的 `player` 通过视频 URL 进行初始化；

- `viewDidAppear` 方法中：：
  - 调用 `playViewController` 的 `player` 方法开始播放视频；

- `playViewController` 的 Getter 代码中：
  -  设置了 `playViewController` 的 `allowsPictureInPicturePlayback`，其默认值为 `YES`，这里“多此一举”写明只是提示作用。
  - 设置了 `canStartPictureInPictureAutomaticallyFromInline`，其默认值为 `NO`。如果我们的 `playViewController.view` 宽度撑满了整个屏幕，该属性其实无意义。如果布局进行调整，让 `playViewController.view` 宽度非撑满了整个屏幕，则在 `canStartPictureInPictureAutomaticallyFromInline` 为 `NO` 的情况下，App 推后台无法自动开启 PiP。



最后，`PIPStandardPlayerViewController ` 作为 `playViewController` 的 `delgegate` ，常用的 `AVPlayerViewControllerDelegate` 方法如下，根据函数名可理解方法的调用场景，完整的 Protocol 可以参考 [`AVPlayerViewControllerDelegate`](https://developer.apple.com/documentation/avkit/avplayerviewcontrollerdelegate?language=objc)：

```Objective-C
/// WillStart
- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController {
    [[PIPActivePlayerViewControllerStorage sharedInstance] storePlayerViewController:self];
}
/// DidStart 
- (void)playerViewControllerDidStartPictureInPicture:(AVPlayerViewController *)playerViewController {
}
/// FailedToStart 
- (void)playerViewController:(AVPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error {
    [[PIPActivePlayerViewControllerStorage sharedInstance] removePlayerViewController:self];
}
/// WillStop
- (void)playerViewControllerWillStopPictureInPicture:(AVPlayerViewController *)playerViewController {
}
/// DidStop
- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController {
    [[PIPActivePlayerViewControllerStorage sharedInstance] removePlayerViewController:self];
}
/// restoreUserInterface
- (void)playerViewController:(AVPlayerViewController *)playerViewController
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    [self.delegate restorePlayerViewController:self withCompletionHandler:completionHandler];
}
/// ShouldAutomaticallyDismiss
- (BOOL)playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart:(AVPlayerViewController *)playerViewController {
    return YES;
}
```

在上述代码中：

- 我们在 PiP 开始时，存储当前 `viewController`，在开启失败或者关闭后，移除 `viewController` 的存储。

- `playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart` 表示，如果用户当前正在全屏观看视频时切换 PiP，是否帮用户退出全屏，在这里设置为 `YES` 体验会更好。



## 自定义播放器中的 PiP

### 辅助工具或服务

#### 播放控件 PIPCustomPlayerControlsView & PIPCustomPlayerControlsViewDelegate

![播控](./在 iOS App 上添加“画中画(PiP)”功能.assets/播控.jpeg)

我们将播放控件抽离，只关心 PiP 的核心逻辑，播放控件被抽离为单独的视图，并提供代理，`PIPHomeViewController` 将作为其代理：

```Objective-C
@class PIPCustomPlayerControlsView;
 
@protocol PIPCustomPlayerControlsViewDelegate <NSObject>
 
@property(nonatomic, assign) BOOL isPlaying;
 
- (void)controlsView:(PIPCustomPlayerControlsView *)controlsView updatePlayStatus:(BOOL)isPlaying;
 
- (void)enterPipWithControlsView:(PIPCustomPlayerControlsView *)controlsView;
 
@end
 
@interface PIPCustomPlayerControlsView : UIView
 
@property(nonatomic, weak) id<PIPCustomPlayerControlsViewDelegate> delegate;
 
- (void)updatePipEnable:(BOOL)enable;
 
- (void)updateProgress:(float)progress;
 
@end
```



#### 自定义播放器 PIPPlayerViewProtocol & PIPPlayerViewDelegate

我们将实现不同的自定义播放器 PiP 方案，因此，我们抽象了 `playerView` 的实现为 `PIPPlayerViewProtocol`。 持有自定义播放器的 `playerView` 的 `PIPCustomPlayerViewController` 不关心播放器的实现细节：

```Objective-C
@protocol PIPPlayerViewProtocol <NSObject>
 
@property (nonatomic, assign) BOOL isPlaying;
 
@property (nonatomic, weak) id<PIPPlayerViewDelegate> delegate;
 
- (instancetype)initWithVideoUrl:(NSURL *)url;
 
- (CMTime)duration;
 
#pragma mark - Action
 
- (void)play;
 
- (void)pause;
 
- (void)skipByInterval:(NSTimeInterval)skipInterval completionHandler:(void (^)(NSTimeInterval currentSeconds))completionHandler;
 
#pragma mark - PiPController
 
- (AVPictureInPictureController *)createPiPController;
 
@optional
 
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController;
 
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController;
 
@end
```

```Objective-C
@protocol PIPPlayerViewDelegate <NSObject>
 
- (void)playerView:(UIView<PIPPlayerViewProtocol> *)playerView updateProgress:(CGFloat)progress;
 
@optional
- (void)restorePlayerView:(UIView<PIPPlayerViewProtocol> *)playerView;
 
@end
```



### 自定义播放器 PIPCustomPlayerViewController

#### 属性定义 & Getter

我们的自定义视图，公开的头文件声明如下：

```Objective-C
@protocol PIPPlayerViewControllerDelegate;
 
typedef NS_ENUM(NSInteger, PIPCustomPlayerViewType) {
    PIPCustomPlayerViewTypeNormal,
    PIPCustomPlayerViewTypeSampleBuffer,
    PIPCustomPlayerViewTypeImageSampleBuffer,
    PIPCustomPlayerViewTypePrivateApi,
};
 
@interface PIPCustomPlayerViewController : UIViewController
 
@property (nonatomic, assign) PIPCustomPlayerViewType type;
 
@property (nonatomic, weak) id<PIPPlayerViewControllerDelegate> delegate;
 
@end
```

在上述的代码中：

- 我们添加了自定义视图的类型字段，在后文将依次实现。

- `PIPPlayerViewControllerDelegate` 在上一节“辅助工具或服务”中已经提到，我们将 `playViewController` 的恢复，代理给 `PIPHomeViewController` 处理。



私有的属性如下，包括 画中画控制器 `pipController`、播放器视图 `playerView`、播放控件视图 `controlsView` 、播放控件的隐藏状态 `hiddenControlsView`：

```Objective-C
@interface PIPCustomPlayerViewController ()
<
PIPPlayerViewDelegate,
PIPCustomPlayerControlsViewDelegate,
AVPictureInPictureControllerDelegate
>
 
/// 画中画控制器
@property (nonatomic, strong) AVPictureInPictureController *pipController;
 
/// 播放器视图
@property (nonatomic, strong) UIView<PIPPlayerViewProtocol> *playerView;
 
/// 播放控件视图
@property (nonatomic, strong) PIPCustomPlayerControlsView *controlsView;
 
/// 播放控件视图隐藏状态
@property (nonatomic, assign) BOOL hiddenControlsView;
 
@end
```



继续查看 Getter 相关代码：

```Objective-C
#pragma mark - Getter
 
- (BOOL)isPlaying {
    return self.playerView.isPlaying;
}
 
+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsPlaying {
    return [NSSet setWithObjects:@"playerView.isPlaying", nil];
}
 
- (UIView<PIPPlayerViewProtocol> *)playerView {
    if (!_playerView) {
        switch (self.type) {
            case PIPCustomPlayerViewTypeNormal:
                _playerView = [[PIPNormalPlayerView alloc] initWithVideoUrl:[PIPResourcesManager videoUrl]];
                break;
            case PIPCustomPlayerViewTypeSampleBuffer:
                _playerView = [[PIPSampleBufferPlayerView alloc] initWithVideoUrl:[PIPResourcesManager videoUrl]];
                break;
            case PIPCustomPlayerViewTypeImageSampleBuffer:
                _playerView =  [[PIPImageSampleBufferPlayerView alloc] initWithVideoUrl:[PIPResourcesManager videoUrl]];
                break;
            case PIPCustomPlayerViewTypePrivateApi:
                _playerView = [[PIPPrivateApiPlayerView alloc] initWithVideoUrl:[PIPResourcesManager videoUrl]];
                break;
        }
        _playerView.delegate = self;
    }
    return _playerView;
}
 
- (PIPCustomPlayerControlsView *)controlsView {
    if (!_controlsView) {
        _controlsView = [[PIPCustomPlayerControlsView alloc] initWithFrame:CGRectZero];
        _controlsView.delegate = self;
    }
    return _controlsView;
}
```

在上述代码中：

- 播放控件视图需要  `PIPCustomPlayerViewController` 提供是否正在播放的状态，该状态实际由播放器视图提供。

- 播放器视图将根据不同的 type 类型进行不同的初始化。



#### Lifecycle & UI

在 `ViewDidLoad` 时，初始化 UI，并根据前文提到的支持 PiP 的判断，进行 `pipController` 的构造、播放控件的更新：

```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupUI];
    
    if (AVPictureInPictureController.isPictureInPictureSupported) {
        self.pipController = [self.playerView createPiPController];
        self.pipController.delegate = self;
        [self.controlsView updatePipEnable:YES];
    } else {
        [self.controlsView updatePipEnable:NO];
    }
}
```

> 这里使用 KVO 方式会使代码更健壮。



我们的 UI 只有播放器视图 `playerView`、播放控件视图 `controlsView`，其中，点击屏幕会触发播放控件视图的隐藏与展示逻辑：

```Objective-C
#pragma mark - UI
 
- (void)__setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__handleViewTapped:)]];
    
    [self.view addSubview:self.playerView];
    self.playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.playerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.playerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.playerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.playerView.heightAnchor constraintEqualToConstant:300.0],
    ]];
    
    [self.view addSubview:self.controlsView];
    self.controlsView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.controlsView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16.0],
        [self.controlsView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:- 16.0],
        [self.controlsView.topAnchor constraintEqualToAnchor:self.playerView.bottomAnchor constant:8.0],
        [self.controlsView.heightAnchor constraintEqualToConstant:30.0],
    ]];
}
 
- (void)__hiddenControlsView:(BOOL)hiddenControlsView {
    self.hiddenControlsView = !self.hiddenControlsView;
    [UIView animateWithDuration:0.3 animations:^{
        self.controlsView.alpha = self.hiddenControlsView ? 0 : 1;
    }];
}
 
#pragma mark - Action
 
- (void)__handleViewTapped:(UITapGestureRecognizer *)tapGesture {
    [self __hiddenControlsView:!self.hiddenControlsView];
}
```



#### 播放控件代理 PIPCustomPlayerControlsViewDelegate

作为播放控件的代理， `PIPCustomPlayerControlsViewDelegate` 方法较为简单：

```Objective-C
#pragma mark - PIPCustomPlayerControlsViewDelegate
 
- (void)controlsView:(PIPCustomPlayerControlsView *)controlsView updatePlayStatus:(BOOL)isPlaying {
    if (!isPlaying) {
        [self __pause];
    } else {
        [self __play];
    }
}
 
- (void)enterPipWithControlsView:(PIPCustomPlayerControlsView *)controlsView {
    if (!self.pipController.isPictureInPictureActive) {
        [self.pipController startPictureInPicture];
    }
}
```

在上述代码中：

- 处理了“播放/暂停”按钮事件；
- 实现了 enter PiP 的能力。



#### 自定义播放器代理 PIPPlayerViewDelegate

我们继续补充播放器代理 `PIPPlayerViewDelegate` 所需要实现的方法：

```Objective-C
#pragma mark - PIPPlayerViewDelegate
 
- (void)playerView:(nonnull UIView<PIPPlayerViewProtocol> *)playerView updateProgress:(CGFloat)progress {
    [self.controlsView updateProgress:progress];
    if (progress == 1.0) {
        [self __pause];
        if (self.pipController.pictureInPictureActive) {
            [self __stopPictureInPicture];
        }
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nil;
    }
}
 
- (void)__stopPictureInPicture {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        SEL selStopPictureInPicture = NSSelectorFromString([NSString stringWithFormat:@"stopPictureInPictureEvenWhenInBackground"]);
        if ([self.pipController respondsToSelector:selStopPictureInPicture]) {
            ((void(*)(id, SEL))objc_msgSend)(self.pipController, selStopPictureInPicture);
            return;
        }
    }
    [self.pipController stopPictureInPicture];
}
 
- (void)restorePlayerView:(nonnull UIView<PIPPlayerViewProtocol> *)playerView {
    // Todo
}
```

在上述代码中：

- 在播放器回调进度后，我们更新控制器的视图的进度条，当播放进度为 1 时，我们将关闭 PiP。这里我们将 `nowPlayingInfo` 设置为 `nil`， 后续将讲到。

> 这里需要注意，当应用程序处于非活动状态或在后台, `stopPictureInPicture` 方法并不会生效，这里使用了私有 API，请根据需求酌情使用。

- `restorePlayerView: ` 将在后续具体方案中实现。 



#### 播放控制

`playerViewController` 的实际播放、暂停、快进、后退，将交给 `playerView` 处理：

```Objective-C
- (void)__play {
    [self.playerView play];
    [self.pipController invalidatePlaybackState];
}
 
- (void)__pause {
    [self.playerView pause];
    [self.pipController invalidatePlaybackState];
}
 
- (void)__skipByInterval:(NSTimeInterval)skipInterval completionHandler:(void (^)(NSTimeInterval currentSeconds))completionHandler {
    [self.playerView skipByInterval:skipInterval completionHandler:completionHandler];
}
```

[`invalidateplaybackstate`](https://developer.apple.com/documentation/avkit/avpictureinpicturecontroller/3750328-invalidateplaybackstate?language=objc) 函数的调用来自 Apple 文档：

> - 使控制器当前播放状态无效，并从 sample buffer playback delegate 对象中获取更新后的状态。
>
> - 每当开始或暂停播放以及基础内容持续时间更改时，调用此方法。



#### pipController 代理 AVPictureInPictureControllerDelegate

作为 `pipController` 的代理，根据需要实现其代理方法，这里类似标准播放器的 `AVPlayerViewControllerDelegate`：

```Objective-C
#pragma mark - AVPictureInPictureControllerDelegate

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self __hiddenControlsView:YES];
    [[PIPActivePlayerViewControllerStorage sharedInstance] storePlayerViewController:self];
}
 
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    if ([self.playerView respondsToSelector:@selector(pictureInPictureControllerDidStartPictureInPicture:)]) {
        [self.playerView pictureInPictureControllerDidStartPictureInPicture:pictureInPictureController];
    }
    [self __setupRemoteCommandsAndNowPlayingInfo];
}
 
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
failedToStartPictureInPictureWithError:(NSError *)error {
    [[PIPActivePlayerViewControllerStorage sharedInstance] removePlayerViewController:self];
}
 
- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
}
 
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    if ([self.playerView respondsToSelector:@selector(pictureInPictureControllerDidStopPictureInPicture:)]) {
        [self.playerView pictureInPictureControllerDidStopPictureInPicture:pictureInPictureController];
    }
    [self __disableRemoteCommands];
    [[PIPActivePlayerViewControllerStorage sharedInstance] removePlayerViewController:self];
}
 
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    [self.delegate restorePlayerViewController:self withCompletionHandler:completionHandler];
}
```

在上述代码中：

- 在 WillStart 生命周期时，我们隐藏了播放控件，并将当前 `playViewController` 存储。

- 在 DidStart 生命周期后：
  - 我们将事件通知给 `playerView`，不同方案的 `playView` 将根据需要使用。
  - 我们设置了 `RemoteCommands` 和 `NowPlayingInfo`，在后续将会提到。

- 在 DidStop 生命周期后：
  - 我们将事件通知给 `playerView`，不同方案的 `playView` 将根据需要使用。
  - 将 `RemoteCommands` 进行清理，在后续将会提到。
  - 将当前 `playViewController` 存储移除。

- 在 PiP 恢复时，我们将事件代理给 `PIPHomeViewController` 进行可能需要的 `viewControllers` 处理。



####  正在播放 RemoteCommand & NowPlayingInfo

<img src="./在 iOS App 上添加“画中画(PiP)”功能.assets/RemoteCommands1.jpeg" alt="RemoteCommands1" style="zoom: 33%;" />

<img src="./在 iOS App 上添加“画中画(PiP)”功能.assets/RemoteCommands2-6432358.jpeg" alt="RemoteCommands2" style="zoom: 33%;" />

<img src="./在 iOS App 上添加“画中画(PiP)”功能.assets/RemoteCommands3.jpeg" alt="RemoteCommands3" style="zoom: 33%;" />



如果我们想设置当前正在播放的信息和相应相应播放控件的操作，那么我们需要设置：

```Objective-C
#pragma mark - RemoteCommand & NowPlayingInfo
 
- (void)__setupRemoteCommandsAndNowPlayingInfo {
    [MPRemoteCommandCenter sharedCommandCenter].playCommand.enabled = YES;
    [MPRemoteCommandCenter sharedCommandCenter].pauseCommand.enabled = YES;
    [MPRemoteCommandCenter sharedCommandCenter].skipForwardCommand.enabled = YES;
    [MPRemoteCommandCenter sharedCommandCenter].skipForwardCommand.preferredIntervals = @[@(15)];
    [MPRemoteCommandCenter sharedCommandCenter].skipBackwardCommand.enabled = YES;
    [MPRemoteCommandCenter sharedCommandCenter].skipBackwardCommand.preferredIntervals = @[@(15)];
    
    __weak typeof(self) weakSelf = self;
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf __play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf __pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].skipForwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(self) strongSelf = weakSelf;
        MPSkipIntervalCommand *command = (MPSkipIntervalCommand *)event.command;
        NSTimeInterval skipInterval = command.preferredIntervals[0].floatValue;
        [strongSelf __skipByInterval:skipInterval completionHandler:^(NSTimeInterval currentSeconds) {
            NSMutableDictionary *infoDic = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo.mutableCopy;
            [infoDic setObject:@(currentSeconds) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = infoDic;
        }];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    [[MPRemoteCommandCenter sharedCommandCenter].skipBackwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        __strong typeof(self) strongSelf = weakSelf;
        MPSkipIntervalCommand *command = (MPSkipIntervalCommand *)event.command;
        NSTimeInterval skipInterval = command.preferredIntervals[0].floatValue * (-1);
        [strongSelf __skipByInterval:skipInterval completionHandler:^(NSTimeInterval currentSeconds) {
            NSMutableDictionary *infoDic = [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo.mutableCopy;
            [infoDic setObject:@(currentSeconds) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
            [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = infoDic;
        }];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
    [infoDic setObject:@"MPMediaItemPropertyAlbumTitle" forKey:MPMediaItemPropertyAlbumTitle];
    [infoDic setObject:@"MPMediaItemPropertyTitle" forKey:MPMediaItemPropertyTitle];
    [infoDic setObject:[[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(50, 50) requestHandler:^UIImage * _Nonnull(CGSize size) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"icon" ofType:@"png"];
        return [UIImage imageWithContentsOfFile:imagePath];
    }] forKey:MPMediaItemPropertyArtwork];
    Float64 duration = CMTimeGetSeconds([self.playerView duration]);
    [infoDic setObject:@(duration) forKey:MPMediaItemPropertyPlaybackDuration];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = infoDic;
}
 
- (void)__disableRemoteCommands {
    [MPRemoteCommandCenter sharedCommandCenter].playCommand.enabled = NO;
    [MPRemoteCommandCenter sharedCommandCenter].pauseCommand.enabled = NO;
    [MPRemoteCommandCenter sharedCommandCenter].skipForwardCommand.enabled = NO;
    [MPRemoteCommandCenter sharedCommandCenter].skipBackwardCommand.enabled = NO;
}
```

在上述代码中：

- 我们分别设置了播放、暂停、快进、后退播放控件的相应，以及配置了当前播放的信息。



### 播放器视图 PIPPlayerViewProtocol

#### 使用 initWithPlayerLayer: 构造 pipController

`AVPlayer` 是一个可以播放多种格式的全功能影音播放器，存在于 `AVFoundation` 框架中。相对于 `AVPlayerViewController`，支持高度可定制。`AVPlayer` 播放界面中不带播放控件，播放视频需要加入 `AVPlayerLayer` 中，并添加到其显示的 `layer` 当中。 PiP 中无法展示除视频以外的内容。

##### PIPNormalPlayerView

![Custom player](./在 iOS App 上添加“画中画(PiP)”功能.assets/Custom player.gif)

我们将以上述方式，实现 `PIPNormalPlayerView`。其属性如下：

```Objective-C
@interface PIPNormalPlayerView ()
 
@property (nonatomic, strong) AVPlayer *player;
 
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
 
@property (nonatomic, strong) id timeObserver;
 
@end
```

在上述代码中：

- `player` 和 `playerLayer` 将用于视频播放；

- `timeObserver`  将用来做进度更新。



继续查看代码：

```Objective-C
- (instancetype)initWithVideoUrl:(NSURL *)url {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        
        _player = [AVPlayer playerWithURL:url];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.layer addSublayer:_playerLayer];
        
        __weak typeof(self) weakSelf = self;
        self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:^(CMTime time) {
            __strong typeof(self) strongSelf = weakSelf;
            CGFloat progress = CMTimeGetSeconds(strongSelf.player.currentItem.currentTime) / CMTimeGetSeconds(strongSelf.player.currentItem.duration);
            [strongSelf.delegate playerView:strongSelf updateProgress:progress];
        }];
    }
    return self;
}
 
- (void)dealloc {
    [_player removeTimeObserver:_timeObserver];
}
```

在上述代码中：

- 我们根据视频 URL，构造了 `AVPlayer`，并构造 `AVPlayerLayer`，将其添加到当前 `PIPNormalPlayerView` 的 `layer` 上；

- `addPeriodicTimeObserverForInterval:queue:usingBlock:` 是在正常播放期间遍历指定时间，在指定线程上调用 block。我们希望播放器调用时间观察器，就必须保留此返回值。这里我们以 0.5s 的频率进行更新；
- 在 `dealloc` 释放 `_timeObserver` 前，不调用 `removeTimeObserver:` 会导致未定义的行为。



在 `layoutSubviews` 进行 UI 调整：

```Objective-C
- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}
```



按照 `PIPPlayerViewProtocol`，实现我们所需的属性或方法，播放状态、时常、播放、暂停、快进或后退的实现：

```Objective-C
- (BOOL)isPlaying {
    return (self.player.rate != 0) && (self.player.error == nil);
}
 
+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsPlaying
{
    return [NSSet setWithObjects:@"player.rate", @"player,error", nil];
}
 
- (CMTime)duration {
    return self.player.currentItem.asset.duration;
}
 
- (void)play {
    [self.player play];
}
 
- (void)pause {
    [self.player pause];
}
 
- (void)skipByInterval:(NSTimeInterval)skipInterval completionHandler:(void (^)(NSTimeInterval currentSeconds))completionHandler {
    CMTime currentTime = CMTimeMake(self.player.currentTime.value + self.player.currentTime.timescale * skipInterval, self.player.currentTime.timescale);
    if (CMTimeCompare(currentTime, kCMTimeZero) < 0) {
        currentTime = kCMTimeZero;
    } else if (CMTimeCompare(currentTime, [self duration]) > 0) {
        currentTime = [self duration];
    }
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            completionHandler(currentTime.value / currentTime.timescale);
        }
    }];
}
```



最后，提供 pipController 创建的方法：

```Objective-C
- (AVPictureInPictureController *)createPiPController {
    AVPictureInPictureController *pipController = [[AVPictureInPictureController alloc] initWithPlayerLayer:self.playerLayer];
    pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
    return pipController;
}
```



#### 使用 initWithSampleBufferDisplayLayer:playbackDelegate: 构造 pipController

[`AVSampleBufferDisplayLayer`](https://developer.apple.com/documentation/avfoundation/avsamplebufferdisplaylayer?language=objc) 是展示视频帧的对象，继承自 `CALayer`，可以直接将其添加到展示的 `layer` 上。用来一帧一帧展示视频的内容，每一帧展示的内容由开发者来提供。PiP 的长宽比例也由 `AVSampleBufferDisplayLayer` 当前正在展示的这一帧内容的长宽比决定。

`AVSampleBufferDisplayLayer` 的重要方法是 [`enqueueSampleBuffer:`](https://developer.apple.com/documentation/avfoundation/avsamplebufferdisplaylayer/1387599-enqueuesamplebuffer)，发送用于显示的`sampleBuffer`。`sampleBuffer` 的类型是 `CMSampleBufferRef`：

```Objective-C
- (void)enqueueSampleBuffer:(CMSampleBufferRef)sampleBuffer;
```

 `AVSampleBufferDisplayLayer` 的展示需要提供 `CMSampleBufferRef` ，一般客户端获取的原始帧格式是 `CVPixelBuffer`，因此需要端上执行一次转换。



`AVSampleBufferDisplayLayer`的重要属性是 [`controlTimebase`](https://developer.apple.com/documentation/avfoundation/avsamplebufferdisplaylayer/1390569-controltimebase?language=objc)，它用于**解释**时间戳：

```Objective-C
@property (retain, nullable) __attribute__((NSObject)) CMTimebaseRef controlTimebase;
```

可以通过 `controlTimebase` 来给当前的 `AVSampleBufferDisplayLayer` 的播放速率与进度，但只是“解释”视频的播放速率和进度，而视频真正的变化还是需要开发者额外去实现。

> 根据 Apple 的文档，在调用 `enqueueSampleBuffer:` 后，不能再更改  `controlTimebase`。



这里还有一个 `playbackDelegate` 参数，使用  `AVSampleBufferDisplayLayer ` 来渲染 PiP 内容时，系统无法完成 PiP 的播控操作，交由开发者实现了 [`AVPictureInPictureSampleBufferPlaybackDelegate`](https://developer.apple.com/documentation/avkit/avpictureinpicturesamplebufferplaybackdelegate) 的 `delegate` 进行处理。



##### PIPSampleBufferPlayerView

![Custom player & SampleBuffer](./在 iOS App 上添加“画中画(PiP)”功能.assets/Custom player & SampleBuffer.gif)

我们的 `PIPSampleBufferPlayerView` 有以下属性：

```Objective-C
@interface PIPSampleBufferPlayerView () <AVPictureInPictureSampleBufferPlaybackDelegate>
 
@property (nonatomic, strong) AVPlayer *player;
 
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;
 
@property (nonatomic, strong) CADisplayLink *displayLink;
 
@property (nonatomic, strong) AVSampleBufferDisplayLayer *sampleBufferDisplayLayer;
 
@property (nonatomic, strong) id timeObserver;
 
@end
```

在上述代码中：

- `CADisplayLink` 是一个能让我们以和屏幕刷新率相同的频率将内容画到屏幕上的定时器。我们在应用中创建一个新的 `CADisplayLink` 对象，把它添加到一个`runloop`中，并给它提供一个 `target` 和`selector` 在屏幕刷新的时候调用。

- 这里的 `player` 只是将我们的 .mp4 文件的每一帧 `CVPixelBufferRef`，输出到 `videoOutput` 中，通过 `displayLink` 的调用，将这些 `CVPixelBufferRef` 转换为 `CMSampleBufferRef`，通过 `enqueueSampleBuffer:` 展示在 `sampleBufferDisplayLayer` 上。后续将看到具体实现方式。



首先，我们更改了 `PIPSampleBufferPlayerView` 的 `layerClass`：

```Objective-C
+ (Class)layerClass {
    return [AVSampleBufferDisplayLayer class];
}
 
- (AVSampleBufferDisplayLayer *)sampleBufferDisplayLayer {
    return (AVSampleBufferDisplayLayer *)self.layer;
}
```



继续添加代码：

```Objective-C
- (instancetype)initWithVideoUrl:(NSURL *)url {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        
        _player = [AVPlayer playerWithURL:url];
        _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:@{
            (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        }];
        [_player.currentItem addOutput:_videoOutput];
        
        _displayLink = [CADisplayLink displayLinkWithTarget:[PIPWeakProxy proxyForObject:self] selector:@selector(__displayLinkDidRefreshed:)];
        
        [self __setupTimebase];
        
        __weak typeof(self) weakSelf = self;
        _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC)
                                                              queue:dispatch_get_main_queue()
                                                         usingBlock:^(CMTime time) {
            __strong typeof(self) strongSelf = weakSelf;
            CGFloat progress = CMTimeGetSeconds(strongSelf.player.currentItem.currentTime) / CMTimeGetSeconds(strongSelf.player.currentItem.duration);
            [strongSelf.delegate playerView:strongSelf updateProgress:progress];
        }];
    }
    return self;
}
 
- (void)dealloc {
    [_player removeTimeObserver:_timeObserver];
}
```



在上述代码中：

- 我们初始化了 `_player`、将 `_videoOutput` 配置后，作为 `_player` 的输出。

- 启动 `_displayLink`，按照定义调用 `__displayLinkDidRefreshed:` 方法。

- 设置 `Timebase`，稍后看到详细代码。

- `_timeObserver` 添加进度回调功能。

- `dealloc` 时 `removeTimeObserver`。



`__displayLinkDidRefreshed:`  和  `enqueueSampleBuffer:`  的处理如下：

```Objective-C
- (void)__displayLinkDidRefreshed:(CADisplayLink *)link {
    CMTime itemTime = [self.videoOutput itemTimeForHostTime:CACurrentMediaTime()];
    if ([self.videoOutput hasNewPixelBufferForItemTime:itemTime]) {
        CMTime outItemTimeForDisplay = kCMTimeZero;
        CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:itemTime itemTimeForDisplay:&outItemTimeForDisplay];
        [self __displayPixelBuffer:pixelBuffer];
    }
}
 
- (void)__displayPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer){
        return;
    }
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    CFRelease(pixelBuffer);
    CFRelease(videoInfo);
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    if (self.sampleBufferDisplayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [self.sampleBufferDisplayLayer flush];
    }
    [self.sampleBufferDisplayLayer enqueueSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
}
```



`__setupTimebase`的处理如下，进行播放速率与进度的处理：

```Objective-C
 - (void)__setupTimebase {
    CMTimebaseRef timebase;
    CMTimebaseCreateWithSourceClock(nil, CMClockGetHostTimeClock(), &timebase);
    CMTimebaseSetTime(timebase, kCMTimeZero);
    CMTimebaseSetRate(timebase, 1);
    self.sampleBufferDisplayLayer.controlTimebase = timebase;
    if (timebase) {
        CFRelease(timebase);
    }
}
```



`isPlaying` 属性、长度、播放、暂停、快进、后退如下：

```Objective-C
- (BOOL)isPlaying {
    return (self.player.rate != 0) && (self.player.error == nil);
}
 
+ (NSSet<NSString *> *)keyPathsForValuesAffectingIsPlaying {
    return [NSSet setWithObjects:@"player.rate", @"player,error", nil];
}
 
- (CMTime)duration {
    return self.player.currentItem.asset.duration;
}
 
- (void)play {
    if (!self.isPlaying) {
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self.player play];
    }
}
 
- (void)pause {
    if (self.isPlaying) {
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self.player pause];
    }
}

- (void)skipByInterval:(NSTimeInterval)skipInterval completionHandler:(void (^)(NSTimeInterval currentSeconds))completionHandler {
    CMTime currentTime = CMTimeMake(self.player.currentTime.value + self.player.currentTime.timescale * skipInterval, self.player.currentTime.timescale);
    if (CMTimeCompare(currentTime, kCMTimeZero) < 0) {
        currentTime = kCMTimeZero;
    } else if (CMTimeCompare(currentTime, [self duration]) > 0) {
        currentTime = [self duration];
    }
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            CMTimebaseSetTime(self.sampleBufferDisplayLayer.controlTimebase, currentTime);
            completionHandler(currentTime.value / currentTime.timescale);
        }
    }];
}
```



处理 PiP 的播控逻辑 `AVPictureInPictureSampleBufferPlaybackDelegate` 如下：

```Objective-C
///  PiP 窗口大小改变
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
         didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    
}
 
/// 点击 PiP 窗口中的播放/暂停
- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController
                        setPlaying:(BOOL)playing {
    if (playing) {
        [self play];
    } else {
        [self pause];
    }
}
 
/// 点击 PiP 窗口中的快进后图
- (void)pictureInPictureController:(nonnull AVPictureInPictureController *)pictureInPictureController
                    skipByInterval:(CMTime)skipInterval completionHandler:(nonnull void (^)(void))completionHandler {
    [self skipByInterval:(skipInterval.value / skipInterval.timescale)
       completionHandler:^(NSTimeInterval currentSeconds) {
        completionHandler();
    }];
}
 
/// 前视频是否处于暂停状态
/// 当点击播放/暂停按钮时，PiP 会调用该方法，决定 setPlaying: 的值，同时该方法返回值也决定了PiP窗口展示击播放/暂停 icon
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
    return !self.isPlaying;
}
 
/// 视频的可播放时间范围
- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(nonnull AVPictureInPictureController *)pictureInPictureController {
    return CMTimeRangeMake(kCMTimeZero, [self duration]);
}
```



创建 `pipController` 的逻辑如下：

```Objective-C
- (AVPictureInPictureController *)createPiPController {
    AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.sampleBufferDisplayLayer playbackDelegate:self];
    AVPictureInPictureController *pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
    pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
    return pipController;
}
```



#### 使用 AVPictureInPictureViewController

PiP 对应一个 `UIViewController`，这个  `UIViewController `就是 `AVPictureInPictureViewController`，它是`AVPictureInPictureController`的一个私有属性，可以通过以下方式获取：

```Objective-C
//
UIViewController *pipVC = [pipController valueForKey:@"pictureInPictureViewController"];

//
SEL selPiPVC = NSSelectorFromString(@"pictureInPictureViewController");
IMP imp = [pipController methodForSelector:selPiPVC];
UIViewController* (*getPiPVC)(id, SEL) = (void *)imp;
UIViewController *pipVC = getPiPVC(pipController, selPiPVC);
```

拿到 `pictureInPictureViewController` 后，我们用一个播放速度极慢且静音且隐藏的 `PlayerLayer`  或只有一帧且隐藏的 `AVSampleBufferDisplayLayer` 去占位，就可以在打开 PiP 时直接将要展示的内容添加到 `pictureInPictureViewController ` 的 `view` 上。这样展示在 PiP 窗口中的内容就不受限制了，但需要开发者维护展示的内容的转移布局等。



##### PIPPrivateApiPlayerView

![Custom player & Private Api](./在 iOS App 上添加“画中画(PiP)”功能.assets/Custom player & Private Api.gif)

以只有一帧的 `AVSampleBufferDisplayLayer` 去占位为例，`PIPPrivateApiPlayerView` 作为  `AVPictureInPictureSampleBufferPlaybackDelegate`，在 `pictureInPictureControllerDidStartPictureInPicture` 将自己放到 `pipViewController` 上并进行布局：

```Objective-C
- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self removeFromSuperview];
    [self.pipViewController.view addSubview:self];
    [self.pipViewController.view bringSubviewToFront:self];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSLayoutConstraint *constraint in self.constraints) {
        [self removeConstraint:constraint];
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.topAnchor constraintEqualToAnchor:self.pipViewController.view.topAnchor],
        [self.leadingAnchor constraintEqualToAnchor:self.pipViewController.view.leadingAnchor],
        [self.bottomAnchor constraintEqualToAnchor:self.pipViewController.view.bottomAnchor],
        [self.trailingAnchor constraintEqualToAnchor:self.pipViewController.view.trailingAnchor]
    ]];
}
```



我们也需要处理 PiP 的恢复，在 `**AVPictureInPictureSampleBufferPlaybackDelegate**` 的 `pictureInPictureControllerDidStopPictureInPicture` 方法里，我们将事件回调：

```Objective-C
- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self removeFromSuperview];
    [self.delegate restorePlayerView:self];
}
```



在 `PIPCustomPlayerViewController` 中，处理播放器视图的恢复：

```Objective-C
- (void)restorePlayerView:(nonnull UIView<PIPPlayerViewProtocol> *)playerView {
    [self.view addSubview:self.playerView];
    [self.view sendSubviewToBack:self.playerView];
    for (NSLayoutConstraint *constraint in self.playerView.constraints) {
        [self.playerView removeConstraint:constraint];
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.playerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.playerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.playerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.playerView.heightAnchor constraintEqualToConstant:300.0],
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.controlsView.topAnchor constraintEqualToAnchor:self.playerView.bottomAnchor constant:8.0],
    ]];
}
```



