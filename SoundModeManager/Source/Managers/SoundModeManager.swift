// Copyright © 2021 Yurii Lysytsia. All rights reserved.

#if canImport(AVFoundation) && canImport(UIKit)
import class AVFoundation.AVURLAsset
import struct AVFoundation.SystemSoundID
import var AVFoundation.kAudioServicesNoError
import var AVFoundation.kAudioServicesPropertyIsUISound
import func AVFoundation.AudioServicesCreateSystemSoundID
import func AVFoundation.AudioServicesSetProperty
import func AVFoundation.AudioServicesRemoveSystemSoundCompletion
import func AVFoundation.AudioServicesDisposeSystemSoundID
import func AVFoundation.AudioServicesPlaySystemSoundWithCompletion
import class UIKit.DispatchQueue
import class UIKit.UIApplication

public class SoundModeManager: NSObject {
    
    // MARK: - Public Properties
    
    /// Current device's sound mode. Default value is `.notDetermined`.
    ///
    /// To receive the newest value you should call `updateCurrentMode()` method.
    public private(set) var currentMode: SoundMode = .notDetermined
    
    // MARK: - Properties [Private]
    
    /// Weak objects hash table to collect observation tokens.
    private var observationTokens = NSHashTable<ObservationToken>.weakObjects()
    
    /// Returns `true` if sound is currently playing.
    private var isPlaying = false
    
    /// Returns `true` if updating mode timer is scheduled.
    private var isObserved = false
    
    /// Updating current mode timer
    private var updatingModeTimer: DispatchSourceTimer?
    
    /// Time difference between start and finish of mute sound.
    private var lastPlaySoundTimeInterval: TimeInterval?
    
    /// Queue to use when sound playing is scheduled.
    private let updatingQueue = DispatchQueue(label: "\(SoundModeManager.self).updatingQueue", qos: .utility)
    
    // MARK: - Properties [Observers]
    
    /// Notification token holder app enters background.
    private var didEnterBackgroundNotificationToken: NSObjectProtocol?
    
    /// Notification token holder app enters foreground.
    private var willEnterForegroundNotificationToken: NSObjectProtocol?
    
    // MARK: - Properties [Dependencies]
    
    /// Sound to check sound mode state.
    private let soundId: SystemSoundID
    
    /// Sound ID for mute sound.
    private let soundUrl: URL
    
    /// Sound duration in seconds.
    private let soundDuration: TimeInterval
    
    /// Frequency of checking the status in seconds.
    private let soundUpdatingInterval: TimeInterval
    
    /// Weak dependency to notification center.
    private unowned let notificationCenter: NotificationCenter
    
    // MARK: - Inits
    
    /// Create a new instance with given sound URL and other parameters.  and the length greater than 0.5 sec.
    /// - Parameters:
    ///   - soundUrl: URL to the local muted sound file. Sound should be muted.
    ///   - soundUpdatingInterval: Frequency of checking the status in seconds. Should be greater than `1`. Default is `1`.
    ///   - notificationCenter: Notification center dependency to use for observation. Default is `.default`.
    public init(soundUrl: URL, soundUpdatingInterval: TimeInterval = 1, notificationCenter: NotificationCenter = .default) throws {
        // Create a new system sound with given sound URL.
        var soundId: SystemSoundID = 1
        var errorCode = AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
        
        if errorCode != kAudioServicesNoError {
            let userInfo: [String: Any]?
            if #available(iOS 11.3, *) {
                userInfo = [NSLocalizedDescriptionKey: SecCopyErrorMessageString(errorCode, nil) as Any]
            } else {
                userInfo = nil
            }
            
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(errorCode), userInfo: userInfo)
        }
        
        // Configure the new audio system sound to play only in `ring` mode.
        var propertyFlag: UInt32 = 1
        errorCode = AudioServicesSetProperty(
            kAudioServicesPropertyIsUISound,
            UInt32(MemoryLayout.size(ofValue: soundId)),
            &soundId,
            UInt32(MemoryLayout.size(ofValue: propertyFlag)),
            &propertyFlag
        )
        
        if errorCode != kAudioServicesNoError {
            let userInfo: [String: Any]?
            if #available(iOS 11.3, *) {
                userInfo = [NSLocalizedDescriptionKey: SecCopyErrorMessageString(errorCode, nil) as Any]
            } else {
                userInfo = nil
            }
            
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(errorCode), userInfo: userInfo)
        }
        
        // Create sound asset to get duration.
        let soundAsset = AVURLAsset(url: soundUrl)
        
        // Set required properties.
        self.soundId = soundId
        self.soundUrl = soundUrl
        self.soundDuration = soundAsset.duration.seconds
        self.soundUpdatingInterval = max(soundUpdatingInterval, 1)
        self.notificationCenter = notificationCenter
        super.init()
        
        // Observe background/foreground notifications.
        didEnterBackgroundNotificationToken = notificationCenter.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.invalidateObservationTimer()
        }
        
        willEnterForegroundNotificationToken = notificationCenter.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self = self, self.isObserved else { return }
            self.startObservationTimer()
        }
    }
    
    deinit {
        // Remove the custom system sound and completion.
        AudioServicesRemoveSystemSoundCompletion(soundId)
        AudioServicesDisposeSystemSoundID(soundId)
        
        // Remove notification center observers.
        [didEnterBackgroundNotificationToken, willEnterForegroundNotificationToken]
            .compactMap { $0 }
            .forEach { notificationCenter.removeObserver($0) }
    }
    
    // MARK: - Methods
    
    /// Update current state once and notify all observers.
    public func updateCurrentMode(completion: ChangeHandler? = nil) {
        playSound(completion: completion)
    }
    
    /// Subscribe to receive `currentMode` notifications.
    public func observeCurrentMode(changeHandler: @escaping ChangeHandler) -> ObservationToken {
        let token = ObservationToken()
        token.block = changeHandler
        token.manager = self
        observationTokens.add(token)
        return token
    }
    
    /// Begin updating current state, `updateCurrentMode()` method will be called after every `soundCheckInterval` expiration.
    public func beginUpdatingCurrentMode() {
        startObservationTimer()
        isObserved = true
    }
    
    /// Finish updating current state
    public func endUpdatingCurrentMode() {
        invalidateObservationTimer()
        guard isObserved else { return }
        isObserved = false
    }
    
    // MARK: - Helpers
    
    public typealias ChangeHandler = (SoundMode) -> Void
    
    /// Unique observation token to observe sound mode changes.
    public final class ObservationToken: NSObject {
        fileprivate var block: ChangeHandler?
        fileprivate weak var manager: SoundModeManager?
        
        fileprivate override init() { }
        
        deinit {
            invalidate()
        }
        
        /// Invalidate current observation token. Method will be called automatically when an `ObservationToken` is deinited.
        public func invalidate() {
            manager?.observationTokens.remove(self)
        }
    }
    
}

// MARK: - Private

private extension SoundModeManager {
    /// Plays an added muted system sound.
    func playSound(completion: ChangeHandler? = nil) {
        if isPlaying { return }
        
        lastPlaySoundTimeInterval = Date.timeIntervalSinceReferenceDate
        isPlaying = true
        
        AudioServicesPlaySystemSoundWithCompletion(soundId) { [weak self] in
            guard let self = self, let lastPlaySoundTimeInterval = self.lastPlaySoundTimeInterval else { return }
            self.isPlaying = false
            self.lastPlaySoundTimeInterval = nil
            
            // Calculate new state.
            let elapsed = (Date.timeIntervalSinceReferenceDate - lastPlaySoundTimeInterval) < 0.1
            let newState: SoundMode = elapsed ? .silent : .ring
            
            // Update state and notify delegate if needed.
            if newState != self.currentMode {
                self.currentMode = newState
                DispatchQueue.main.async {
                    // Notify all observers.
                    self.observationTokens.allObjects.forEach { $0.block?(newState) }
                    
                    // Notify current caller if exist.
                    completion?(newState)
                }
            }
        }
    }
    
    /// Creates a new timer and schedule it.
    func startObservationTimer() {
        guard updatingModeTimer == nil else { return }
        
        // Create a new timer and resume it.
        let timer = DispatchSource.makeTimerSource(queue: updatingQueue)
        timer.schedule(deadline: .now() + soundUpdatingInterval, repeating: soundUpdatingInterval)
        timer.setEventHandler { [weak self] in
            self?.playSound()
        }
        updatingModeTimer = timer
        timer.resume()
    }
    
    /// Invalidates and remove scheduled timer.
    func invalidateObservationTimer() {
        updatingModeTimer?.cancel()
        updatingModeTimer = nil
    }
}
#endif
