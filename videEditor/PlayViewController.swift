//
//  ViewController.swift
//  videEditor
//
//  Created by Hızlıgelıyo on 4.12.2021.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController {

    var asset : AVAsset?
    var playState : Bool = false
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    
    let videoView : UIView = {
        let x = UIView()
        return x
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setPlayer()
    }
    
    func createUI(){
        view.backgroundColor = .white
        videoView.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        let stopGesture = UITapGestureRecognizer(target: self, action: #selector(stopPlayer(_:)))
        videoView.addGestureRecognizer(stopGesture)
        view.addSubview(videoView)
    }
    
    func setPlayer(){
        if let playingAsset = asset {
            setPlayerItems(avAsset: playingAsset)
        }
    }

    func setPlayerItems(avAsset : AVAsset){
        player = nil
        let item = AVPlayerItem(asset: avAsset)
        player = AVPlayer(playerItem: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        videoView.layer.addSublayer(playerLayer)
        player.play()
        playState = true
    }
    
    @objc func stopPlayer(_ gesture: UITapGestureRecognizer) {
        if playState {
            player.pause()
            playState = false
        }
        else {
            player.play()
            playState = true
        }
    }
    
    @IBAction func unwindSeguetoLoginVC(_ sender: UIStoryboardSegue) {
        
    }
    

    
    
    
 

}

