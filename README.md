# 📴 SoundModeManager 📳
> Detect silent / ring mode on the device.

[![Languages](https://img.shields.io/github/languages/top/yurii-lysytsia/SoundModeManager?color=orange)]()
[![Platforms](https://img.shields.io/cocoapods/p/SoundModeManager)]()
[![CocoaPods](https://img.shields.io/cocoapods/v/SoundModeManager?color=red)]()
[![Build](https://img.shields.io/github/workflow/status/yurii-lysytsia/SoundModeManager/Prepare%20to%20deploy)]()

- [Installation](#-installation)
    - [CocoaPods](#cocoapods)
- [Usage](#-usage)
- [Documentation](#-documentation)
- [License](#-license)

## 🚀 Installation

### [CocoaPods](https://cocoapods.org) 
For usage and installation instructions, visit their website. To integrate AirKit into your Xcode project using CocoaPods, specify it in your `Podfile`:
```ruby
pod 'SoundModeManager'
```

## 💻 Usage 

### Create a new instance of manager:
```swift
import SoundModeManager

// Fully customized instance.
let manager = SoundModeManager(soundUrl: customSoundUrl, soundUpdatingInterval: 5)

// With custom sound file only.
let manager = SoundModeManager(soundUrl: customSoundUrl)

// With default silent sound and custom updating interval. 
let manager = SoundModeManager(soundUpdatingInterval: 5)

// Default manager configuration. 
let manager = SoundModeManager()
```

### Update current mode once (not recommended):
```swift
import SoundModeManager

let manager = SoundModeManager()

// Mode is not determined by default.
manager.currentMode // SoundMode.notDetermined
        
// Update current mode and receive callback.
manager.updateCurrentMode { mode in
    // Mode is `.silent` or `.ring`
    manager.currentMode == mode // true
}
```

### Observe current mode changes:
```swift
import SoundModeManager

let manager = SoundModeManager()

// Mode is not determined by default.
manager.currentMode // SoundMode.notDetermined

// Save token to manage observer and subscribe to receive changes.
let observationToken = sut.observeCurrentMode { mode in
    // Block will be called only when new mode is not the same as previous.  
    // Mode is `.silent` or `.ring`.
    manager.currentMode == mode // true
}

// Start observing current mode.
manager.beginUpdatingCurrentMode()

// End observing current mode. This method suspend all notification, but all observers are still valid.
manager.endUpdatingCurrentMode()
```

### Invalidate observation token:
```swift
// Invalidate observation token is working the same as `NSKeyValueObservation`;
// So you are able to invalidate it manually if you need;
// Token will be invalidated automatically when it is deinited  
observationToken.invalidate()
``` 

## 📜 License
Released under the MIT license. See [LICENSE](LICENSE) for details.
