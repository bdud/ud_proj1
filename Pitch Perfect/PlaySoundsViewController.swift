//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Bill Dawson on 5/12/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit
import AVFoundation


class PlaySoundsViewController: UIViewController {

    var audioPlayer:AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    var receivedAudio : RecordedAudio!
    var audioFile : AVAudioFile!

    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioPlayer.volume = 1.0

        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading:receivedAudio.filePathUrl, error: nil)

        // To come out of speaker on device (instead of ear)
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error: nil)
    }

    // Stops/resets all audio since we use two
    // different means to playback audio (engine vs player)
    func reset() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioEngine.stop()
        audioEngine.reset()
    }

    func playAudioAtRate(rate: Float) {
        reset()
        audioPlayer.rate = rate
        audioPlayer.play()
    }

    func playAudioAtPitch(pitch : Float) {
        reset()

        var pitchPlayer = AVAudioPlayerNode()
        audioEngine.attachNode(pitchPlayer)

        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)

        audioEngine.connect(pitchPlayer, to: changePitchEffect, format: audioFile.processingFormat)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: audioFile.processingFormat)

        pitchPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        pitchPlayer.play()
    }

    // MARK: ACTIONS

    @IBAction func playFast(sender: AnyObject) {
        playAudioAtRate(1.5)
    }

    @IBAction func playSlow(sender: AnyObject) {
        playAudioAtRate(0.5)
    }

    @IBAction func playChipmunkAudio(sender: AnyObject) {
        playAudioAtPitch(1000)
    }

    @IBAction func playDarthvaderAudio(sender: AnyObject) {
        playAudioAtPitch(-1000)
    }

    @IBAction func stop(sender: AnyObject) {
        reset()
    }
}
