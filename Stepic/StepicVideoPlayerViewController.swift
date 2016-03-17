//
//  StepicVideoPlayerViewController.swift
//  StepicVideoPlayer
//
//  Created by Alexander Karpov on 13.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import FLKAutoLayout

class StepicVideoPlayerViewController: UIViewController {
    
    var delegate: PlayerDelegate?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Control views
    @IBOutlet weak var topFullscreenControlsView: UIView!
    @IBOutlet weak var bottomFullscreenControlsView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    
    //Top fullscreen controls
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var currentTimeTopLabel: UILabel!
    @IBOutlet weak var fullTimeTopLabel: UILabel!
    @IBOutlet weak var topTimeProgressView: UIProgressView!
    @IBOutlet weak var topTimeSlider: UISlider!
    
    //Bottom fullscreen controls
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var qualityButton: UIButton!
    @IBOutlet weak var back10SecButton: UIButton!
    @IBOutlet weak var fullscreenPlayButton: UIButton!
    @IBOutlet weak var forward10SecButton: UIButton!
    
    //Seek events
    
    func seekToTime(time: NSTimeInterval) {
        //TODO: Add implementation here
        
        self.player.seekToTime(CMTime(seconds: Double(time), preferredTimescale: 1))
    }
    
    @IBAction func topTimeSliderValueChanged(sender: UISlider) {
        //TODO: Connect with a time here with seekToTime() implementation
        
        let time = NSTimeInterval(sender.value) * self.player.maximumDuration
        seekToTime(time)
    }

    @IBAction func seekForwardPressed(sender: UIButton) {
        //TODO: Add implementation
    }
    @IBAction func seekBackPressed(sender: UIButton) {
        //TODO: Add implementation
    }
    
    //Buffering 
    //TODO: Make this method respond to events
    func bufferingChangedToPercentage(percentage: Float) {
        topTimeProgressView.progress = percentage
    }
    
    @IBAction func backPressed(sender: UIButton) {
        //TODO: Add implementation here
        //Hints: Remove UIWindow with fullscreen controller
    }
    private func makeFullscreenControlsVisible(visible: Bool) {
        topContainerView.hidden = !visible
        bottomFullscreenControlsView.hidden = !visible
    }
    
    //Controlling the rate
    @IBAction func changeRatePressed(sender: UIButton) {
        displayRateChangeAlert()
    }
    
    private func displayRateChangeAlert() {
        let alertController = UIAlertController(title: "Change rate", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        for rate in VideoRate.allValues {
            let action = UIAlertAction(title: rate.description, style: .Default, handler: { 
                action in
                self.currentRate = rate
            })
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private var currentRate : VideoRate = .Normal {
        didSet {
            adjustToCurrentRate()
        }
    }
    
    private func adjustToCurrentRate() {
        self.player.rate = currentRate.rawValue
        rateButton.setTitle("\(currentRate.rawValue)x", forState: .Normal)
    }
    
    
    
    //Controlling the quality
    @IBAction func changeQualityPressed(sender: UIButton) {
        //TODO: Handle player's quality change
    }
    
    
    //Controlling the playback state
    @IBAction func playPressed(sender: UIButton) {
        handlePlay()
    }    
    
    private var player: Player!
    
    let videoUrl = NSURL(string: "https://player.vimeo.com/external/111972892.sd.mp4?s=e25198c6ff128983b1c622477e2089a2&profile_id=112&oauth2_token_id=3605157")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeFullscreenControlsVisible(false)
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        rateButton.setTitle("\(currentRate.rawValue)x", forState: .Normal)
        
        self.player = Player()
        self.player.delegate = self
//        self.player.view.frame = self.view.bounds
        
        self.addChildViewController(self.player)
        self.view.addSubview(self.player.view)
        self.player.view.alignTop("60", leading: "0", bottom: "-40", trailing: "0", toView: self.view)
        self.player.didMoveToParentViewController(self)
        
        self.player.setUrl(videoUrl)
        
        self.player.playbackLoops = false
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGestureRecognizer:")
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.player.view.addGestureRecognizer(tapGestureRecognizer)
        
        topTimeSlider.addTarget(self, action: "finishedSeeking", forControlEvents: UIControlEvents.TouchUpOutside)
        topTimeSlider.addTarget(self, action: "finishedSeeking", forControlEvents: UIControlEvents.TouchUpInside)
        topTimeSlider.addTarget(self, action: "startedSeeking", forControlEvents: UIControlEvents.TouchDown)
    }
    
    private var wasPlayingBeforeSeeking : Bool = false
    func startedSeeking() {
        print("started seeking")
        if self.player.playbackState == .Playing {
            wasPlayingBeforeSeeking = true
            self.player.pause()
        } else {
            wasPlayingBeforeSeeking = false
        }
    }
    
    func finishedSeeking() {
        print("finished seeking")
        if wasPlayingBeforeSeeking {
            self.player.playFromCurrentTime()
        }
    }
    
    // MARK: UIGestureRecognizer
    
    private func handlePlay() {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.Stopped.rawValue:
            self.player.playFromBeginning()
        case PlaybackState.Paused.rawValue:
            self.player.playFromCurrentTime()
        case PlaybackState.Playing.rawValue:
            self.player.pause()
        case PlaybackState.Failed.rawValue:
            self.player.pause()
        default:
            self.player.pause()
        }
        
        if player.playbackState == PlaybackState.Playing {
            fullscreenPlayButton.setTitle("Pause", forState: .Normal)
        } else {
            fullscreenPlayButton.setTitle("Play", forState: .Normal)
        }
    }
    
    func handleTapGestureRecognizer(gestureRecognizer: UITapGestureRecognizer) {
        handlePlay()
    }
    
    private func setTimeParametersAfterPlayerIsReady() {
        fullTimeTopLabel.text = TimeFormatHelper.sharedHelper.getTimeStringFrom(self.player.maximumDuration)
        player.setPeriodicTimeObserver { 
            time in
            self.currentTimeTopLabel.text = TimeFormatHelper.sharedHelper.getTimeStringFrom(CMTimeGetSeconds(time))
            self.topTimeSlider.value = Float(CMTimeGetSeconds(time)/Double(self.player.maximumDuration))
        }
    }
}

extension StepicVideoPlayerViewController : PlayerDelegate {
    func playerReady(player: Player) {
        print("player is ready to display")
        activityIndicator.hidden = true
        makeFullscreenControlsVisible(true)
        setTimeParametersAfterPlayerIsReady()
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
    }
}
