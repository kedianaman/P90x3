//
//  MusicPlayerViewController.swift
//  P90x3
//
//  Created by Naman Kedia on 7/20/17.
//

import UIKit
import MediaPlayer
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    //MARK: IB Outlets

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songArtworkImage: UIImageView!
    @IBOutlet weak var pausePlayButton: UIButton!
    @IBOutlet weak var volumeView: MPVolumeView!
    
    //MARK: Properties
    
    let myMusicPlayer = MPMusicPlayerController()
    let myMusicQuery = MPMediaQuery.songs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMusicInterface()
        self.view.layer.cornerRadius = 10.0
        songArtworkImage.layer.masksToBounds = true
        songArtworkImage.layer.cornerRadius = 5.0
        volumeView.showsRouteButton = false
 
        myMusicPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    @objc func nowPlayingItemChanged(_notification: Notification) {
        updateMusicInterface()
    }
    
    //MARK: IB Actions

   
    @IBAction func backButtonPressed(_ sender: UIButton) {
        myMusicPlayer.skipToPreviousItem()
        sender.bubbleAnimate()
    }
    
    @IBAction func pausePlayButtonPressed(_ sender: UIButton) {
        if sender.imageView?.image == #imageLiteral(resourceName: "Play Music") { // Play Image
            myMusicPlayer.play()
            sender.bubbleAnimate()
        } else if sender.imageView?.image == #imageLiteral(resourceName: "Pause Music") { // Paused Image
            myMusicPlayer.pause()
            sender.bubbleAnimate()
            
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        myMusicPlayer.skipToNextItem()
        sender.bubbleAnimate()
    }
    
    @IBAction func volumeSliderValueChanged(_ sender: Any) {
    }
    //MARK: Helper Function

    func updateMusicInterface() {
        if let nowPlayingSong = myMusicPlayer.nowPlayingItem {
            songTitleLabel.text = nowPlayingSong.title
            songArtworkImage.image = nowPlayingSong.artwork?.image(at: CGSize(width: 50, height: 50))
            artistNameLabel.text = nowPlayingSong.artist
            if myMusicPlayer.playbackState == .playing {
                pausePlayButton.setImage(#imageLiteral(resourceName: "Pause Music"), for: .normal)
            }
            
        } else {
            print("no playing song")
            songTitleLabel.text = "iPhone"
            artistNameLabel.text = "Music"
        }
    }
}

extension UIButton {
    func bubbleAnimate() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
                if self.imageView?.image == #imageLiteral(resourceName: "Play Music") {
                    self.setImage(#imageLiteral(resourceName: "Pause Music"), for: .normal)
                } else if self.imageView?.image == #imageLiteral(resourceName: "Pause Music") {
                    self.setImage(#imageLiteral(resourceName: "Play Music"), for: .normal)
                }
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}
