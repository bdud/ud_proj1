//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Bill Dawson on 5/10/15.
//  Copyright (c) 2015 Bill Dawson. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!

    let labelWhileRecording = "Recording in progress, tap to pause"
    let labelWhileNotRecording = "Tap to record"
    let labelWhilePaused = "Tap to resume recording"
    let audioPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String

    var audioRecorder : AVAudioRecorder!
    var recordedAudio: RecordedAudio!

    private enum RecordingState {
        case NotRecording,
        Recording,
        Paused
    }

    private var currentState : RecordingState = RecordingState.NotRecording

    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
        updateLabel()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playSegue" {
            if let controller = segue.destinationViewController as? PlaySoundsViewController {
                controller.receivedAudio = sender as! RecordedAudio
            }
        }
    }

    func recordAudio() {
        var currentDateTime = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        var recordingName = formatter.stringFromDate(currentDateTime) + ".wav"
        var pathArray = [audioPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)

        // Setup Audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)

        // init and prepare recorder
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()

        self.currentState = RecordingState.Recording
        updateLabel()
        stopButton.hidden = false
    }

    func pauseRecording() {
        audioRecorder.pause()
        self.currentState = RecordingState.Paused
        updateLabel()
    }

    func resumeRecording() {
        audioRecorder.record()
        self.currentState = RecordingState.Recording
        updateLabel()
    }

    func updateLabel() {
        switch self.currentState {
        case .Recording:
            recordingLabel.text = labelWhileRecording
        case .NotRecording:
            recordingLabel.text = labelWhileNotRecording
        case .Paused:
            recordingLabel.text = labelWhilePaused
        }
    }

    // MARK: AVAudioRecorderDelegate

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        self.currentState = RecordingState.NotRecording
        if flag {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url!, title: recorder.url.lastPathComponent!)
            performSegueWithIdentifier("playSegue", sender: recordedAudio)
        }
    }

    // MARK: ACTIONS

    @IBAction func startOrPauseRecording(sender: UIButton) {
        switch self.currentState {
        case .Paused:
            resumeRecording()
        case .Recording:
            pauseRecording()
        case .NotRecording:
            recordAudio()
        }
    }

    @IBAction func stopRecording(sender: AnyObject) {
        audioRecorder.stop()
        AVAudioSession.sharedInstance().setActive(false, error: nil)
    }

}
