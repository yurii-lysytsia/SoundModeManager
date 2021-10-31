// Copyright © 2021 Yurii Lysytsia. All rights reserved.

/// Sound mode on your iPhone.
public enum SoundMode: Int {
    /// Sound mode not determined yet.
    case notDetermined
    
    /// You don't hear ringtones and alerts, but your iPhone can still play sounds, like when you play music or videos.
    case silent
    
    /// You hear ringtones and alerts.
    case ring
}
