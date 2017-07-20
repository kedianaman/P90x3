//
//  MusicPlayerViewController.swift
//  P90x3
//
//  Created by Naman Kedia on 7/20/17.
//

import UIKit
import MediaPlayer

class MusicPlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateMusicInterface()
        self.view.layer.cornerRadius = 10.0
        myMusicPlayer.beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    @objc func nowPlayingItemChanged(_notification: Notification) {
        updateMusicInterface()
    }
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtworkImage: UIImageView!
    let myMusicPlayer = MPMusicPlayerController()
    let myMusicQuery = MPMediaQuery.songs()
    
    @IBAction func backButtonPressed(_ sender: Any) {
        myMusicPlayer.skipToPreviousItem()
    }
    
    @IBAction func pausePlayButtonPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Play" {
            myMusicPlayer.play()
            sender.setTitle("Pause", for: .normal)
        } else if sender.titleLabel?.text == "Pause" {
            myMusicPlayer.pause()
            sender.setTitle("Play", for: .normal)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        myMusicPlayer.skipToNextItem()
    }
    
    func updateMusicInterface() {
        if let nowPlayingSong = myMusicPlayer.nowPlayingItem {
            let songTitle = nowPlayingSong.title
            let albumArtwork = nowPlayingSong.artwork?.image(at: CGSize(width: 50, height: 50))
            songTitleLabel.text = songTitle
            songArtworkImage.image = albumArtwork
            
        } else {
            print("no playing song")
        }
    }
    
    

}
