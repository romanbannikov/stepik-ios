//
//  VideoDownloadView.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class VideoDownloadView: UIView {

    @IBOutlet weak var qualityLabel: UILabel!
    @IBOutlet weak var downloadButton: PKDownloadButton!
    
    var video : Video!
    var quality : VideoQuality!
    
    var view: UIView!
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "VideoDownloadView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        setup()
    } 
    
    convenience init(frame: CGRect, quality: VideoQuality, video: Video, delegate downloadDelegate: PKDownloadButtonDelegate) {
        self.init(frame: frame)
        
        print("frame -> \(self.view.frame)")
        
        self.video = video
        self.quality = quality
        
        downloadButton.delegate = downloadDelegate
        
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton, white: true)
        qualityLabel.text = "\(quality.rawString)p"
        updateButton()
    }
    
    
    func updateButton() {
        if video.isCached {
            downloadButton.state = .Downloaded
            return
        }
        
        if video.isDownloading {
            downloadButton.state = .Downloading
            video.storedProgress = {
                prog in
                UIThread.performUI({self.downloadButton.stopDownloadButton?.progress = CGFloat(prog)})
            }
            video.storedCompletion = {
                completed in
                if completed {
                    UIThread.performUI({self.downloadButton.state = .Downloaded})
                } else {
                    UIThread.performUI({self.downloadButton.state = .StartDownload})
                }
            }
            return
        }
        
        if !video.isCached && !video.isDownloading {
            downloadButton.state = .StartDownload
            return
        }
        
        downloadButton.state = .Pending
        print("Something got wrong while initializing download button state. Should not be pending")
    }

    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}
