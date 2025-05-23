//
//  AudioEffectState.swift
//  TUILiveKit
//
//  Created by adamsfliu on 2024/7/19.
//

import Foundation

enum AudioChangerType: Int {
    case none = 0
    case child = 1
    case littleGirl = 2
    case man = 3
    case ethereal = 11
}

enum AudioReverbType: Int {
    case none = 0
    case KTV = 1
    case smallRoom = 2
    case auditorium = 3
    case deep = 4
    case loud = 5
    case metallic = 6
    case magnetic = 7
}

struct AudioEffectState {
    var isEarMonitorOpened: Bool = false
    var earMonitorVolume: Int = 100
    
    var microphoneVolume: Int = 100
    var voicePitch: Double = 0.0
    
    var currentPlayMusic: String = ""
    
    var changerType: AudioChangerType = .none
    var reverbType: AudioReverbType = .none
}
