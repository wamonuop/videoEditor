//
//  EditViewController.swift
//  videEditor
//
//  Created by Hızlıgelıyo on 4.12.2021.
//



import UIKit
import AVFoundation
import MobileCoreServices
import CoreMedia
import AssetsLibrary
import Photos
import OpalImagePicker

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, OpalImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView?
    
    
    let layout : UICollectionViewFlowLayout = {
       let x = UICollectionViewFlowLayout()
        x.scrollDirection = .horizontal
        x.itemSize = CGSize(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
        x.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
       return x
    }()
    
    let nextStepButton : UIButton = {
       let x = UIButton()
        x.isSelected = false
        x.setTitle("Next Step", for: .normal)
        x.setTitleColor(.systemBlue, for: .normal)
        x.addTarget(self, action: #selector(nextStep), for: .touchUpInside)
        x.backgroundColor = .lightGray
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
       return x
    }()
    
    let addVideoButton : UIButton = {
       let x = UIButton()
        x.setTitle("Add Video", for: .normal)
        x.setTitleColor(.systemBlue, for: .normal)
        x.addTarget(self, action: #selector(selectVideo), for: .touchUpInside)
        x.backgroundColor = .lightGray
        x.layer.cornerRadius = 5
        x.layer.masksToBounds = true
       return x
    }()

    let videoView : UIView = {
        let x = UIView()
        return x
    }()
    
    let frameContainerView : UIView = {
       let x = UIView()
       return x
    }()
    
    let startTimeLabel : UILabel = {
        let x = UILabel()
        return x
    }()
    
    let endTimeLabel : UILabel = {
       let x = UILabel()
       return x
    }()
    
    let imageFrameView : UIView = {
       let x = UIView()
       return x
    }()
    
    
    var mediaUrl : [URL] = []
    var Videos : [Video] = []
    var selectedVideo : Video?
    var selectedIndex : Int?
    var playState : Bool = false
    
    var isSliderEnd = true
    
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerLayer: AVPlayerLayer!
    var asset: AVAsset!
    var assetArray : [AVAsset] = []
    
    var startTime: CGFloat = 0.0
    var stopTime: CGFloat  = 0.0
    var thumbTime: CMTime!
    var thumbTimeArray : [CMTime] = []
    var thumbtimeSeconds: Int!
    var thumbTimeSecondsArray : [Int] = []
    
    var videoPlaybackPosition: CGFloat = 0.0
    var rangeSlider: RangeSlider! = nil
    let mydispatchGroup = DispatchGroup()
    
    //MARK: - View Stuff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identfier)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        view.addSubview(collectionView!)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer(_:)))
        collectionView?.addGestureRecognizer(gesture)
        loadViews()
        let stopGesture = UITapGestureRecognizer(target: self, action: #selector(stopPlayer(_:)))
        videoView.addGestureRecognizer(stopGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    func loadViews(){
        self.view.backgroundColor = .white
        player = AVPlayer()
        addVideoButton.frame = CGRect(x: 20, y: 60, width: 100, height: 30)
        nextStepButton.frame = CGRect(x: UIScreen.main.bounds.width-140, y: 60, width: 120, height: 30)
        frameContainerView.frame = CGRect(x: (UIScreen.main.bounds.width-335) / 2 , y: UIScreen.main.bounds.height-150, width: 335, height: 40)
        imageFrameView.frame = CGRect(x: (UIScreen.main.bounds.width-335) / 2 , y: UIScreen.main.bounds.height-150, width: 335, height: 40)
        videoView.frame = CGRect(x: 0, y: addVideoButton.frame.maxY + 20, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        collectionView?.frame = CGRect(x: 10, y: frameContainerView.frame.minY-120, width: UIScreen.main.bounds.width-20, height: 100)
        frameContainerView.layer.zPosition = 1
        frameContainerView.isUserInteractionEnabled = true
        imageFrameView.isUserInteractionEnabled = true

        
        view.addSubview(addVideoButton)
        view.addSubview(nextStepButton)
        view.addSubview(imageFrameView)
        view.addSubview(frameContainerView)
        view.addSubview(videoView)
    }
    
    //MARK: - CollectionView Stuff
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if Videos.isEmpty {
            return 0
        } else {
            return Videos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identfier, for: indexPath) as! CollectionViewCell
        if Videos.isEmpty {
            return cell
        } else {
            cell.asset = Videos[indexPath.row].asset
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if Videos.isEmpty ||  Videos.count == 1 {
            return
        } else {
            let item = Videos.remove(at: sourceIndexPath.row)
            Videos.insert(item, at: destinationIndexPath.row)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (collectionView.cellForItem(at: indexPath) as? CollectionViewCell) != nil {
            selectedVideo = Videos[indexPath.row]
            selectedIndex = indexPath.row
            videoView.layer.sublayers = nil
            isSliderEnd = true
            if let item = selectedVideo {
                self.thumbtimeSeconds = selectedVideo?.seconds
                self.createRangeSlider()
                self.createImageFrames(asset: item.asset)
                self.setPlayerItems(avAsset: item.asset)
            }
        }
    }
    
    @objc func handleLongPressGestureRecognizer(_ gesture: UILongPressGestureRecognizer){
        
        guard let collectionView = collectionView else { return }
        
        switch gesture.state {
        case .began:
            guard let targetIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
            else { return }
            collectionView.beginInteractiveMovementForItem(at: targetIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    //MARK: - ImagePicker
    
    @objc func selectVideo(){
        let allowedSelectionCount = 5 - Videos.count
        
        if allowedSelectionCount < 0 {
            displayAlert(message: "You reached max video count", title: "Video Editor", send: false)
        }
        else {
            let imagePicker = OpalImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowedMediaTypes = [PHAssetMediaType.video]
            imagePicker.maximumSelectionsAllowed = allowedSelectionCount
            imagePicker.imagePickerDelegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingAssets assets: [PHAsset]) {
        mydispatchGroup.enter()
        if assets.count > 1 {
            for index in 0...assets.count-1 {
                PHCachingImageManager().requestAVAsset(forVideo: assets[index], options: nil) { (avAsset, _, _) in
                    if let x = avAsset {
                        let asset = x
                        self.assetArray.append(x)
                        let thumbTime = x.duration
                        self.thumbTimeArray.append(thumbTime)
                        let seconds = Int(CMTimeGetSeconds(thumbTime))
                        self.thumbTimeSecondsArray.append(seconds)
                        self.thumbtimeSeconds = seconds
                        let newVideo = Video(asset: asset, thumbTime: thumbTime, seconds: seconds, lowerValue: 0, upperValue: Double(seconds))
                        self.Videos.append(newVideo)
                        if assets.count == self.Videos.count {
                            self.mydispatchGroup.leave()
                        }
                    }
                }
            }
        }
        else {
            PHCachingImageManager().requestAVAsset(forVideo: assets[0], options: nil) { (avAsset, _, _) in
                if let x = avAsset {
                    let asset = x
                    self.assetArray.append(x)
                    let thumbTime = x.duration
                    self.thumbTimeArray.append(thumbTime)
                    let seconds = Int(CMTimeGetSeconds(thumbTime))
                    self.thumbTimeSecondsArray.append(seconds)
                    let newVideo = Video(asset: asset, thumbTime: thumbTime, seconds: seconds, lowerValue: 0, upperValue: Double(seconds))
                    self.Videos.append(newVideo)
                    self.mydispatchGroup.leave()
                }
            }
        }
        self.mydispatchGroup.notify(queue: .main){
            if let lastItem = self.Videos.last?.asset{
                self.thumbtimeSeconds = self.Videos.last?.seconds
                let lastVideo = self.Videos.last
                self.selectedIndex = self.Videos.count-1
                self.selectedVideo = lastVideo
                self.createRangeSlider()
                self.createImageFrames(asset: lastItem)
                self.setPlayerItems(avAsset: lastItem)
            }
            self.collectionView?.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Video Thumb Operations
    
    func createImageFrames(asset: AVAsset)
    {
      //creating assets
      let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
      assetImgGenerate.appliesPreferredTrackTransform = true
      assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero;
      assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero;
      
      
      assetImgGenerate.appliesPreferredTrackTransform = true
      let thumbTime: CMTime = asset.duration
      let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
      let maxLength         = "\(thumbtimeSeconds)" as NSString

      let size = thumbtimeSeconds / 5

        
      let thumbAvg  = thumbtimeSeconds/size
      var startTime = 1
      var startXPosition:CGFloat = 0.0
      
        
      for _ in 0...size
      {
        
        let imageButton = UIButton()
        let xPositionForEach = CGFloat(imageFrameView.frame.width)/6
        imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(imageFrameView.frame.height))
        do {
          let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
          let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
          let image = UIImage(cgImage: img)
          imageButton.setImage(image, for: .normal)
        }
        catch
          _ as NSError
        {
          print("Image generation failed with error ")
        }
        
        startXPosition = startXPosition + xPositionForEach
        startTime = startTime + thumbAvg
        imageButton.isUserInteractionEnabled = false
        imageFrameView.addSubview(imageButton)
      }
      
    }

    //MARK: - Player Operations
 
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
    
    func seekVideo(toPos pos: CGFloat) {
      videoPlaybackPosition = pos
      let time: CMTime = CMTimeMakeWithSeconds(Float64(videoPlaybackPosition), preferredTimescale: player.currentTime().timescale)
      player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)

      if(pos == CGFloat(thumbtimeSeconds))
      {
      player.pause()
      }
    }
    
    //MARK: Range Sliders for thumbs
    
    func createRangeSlider(){
        player.pause()
        guard let selectedVideo = selectedVideo else {
            return
        }


        let subViews = frameContainerView.subviews
        for subview in subViews{
          if subview.tag == 1000 {
            subview.removeFromSuperview()
          }
        }

        rangeSlider = RangeSlider(frame: frameContainerView.bounds)
        frameContainerView.addSubview(rangeSlider)
        rangeSlider.tag = 1000
        rangeSlider.lowerValue = Double(selectedVideo.lowerValue)
        rangeSlider.minimumValue = 0.0
        rangeSlider.maximumValue = Double(selectedVideo.seconds)
        rangeSlider.upperValue = Double(selectedVideo.upperValue)
        
        //Range slider action
        rangeSlider.addTarget(self, action: #selector(self.rangeSliderValueChanged(_:)), for: .valueChanged)

        let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
          self.rangeSlider.trackHighlightTintColor = UIColor.clear
          self.rangeSlider.curvaceousness = 1.0
        }
        rangeSlider.isUserInteractionEnabled = true
    }


    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        guard let selectedVideo = selectedVideo else {
            return
        }

        
    if(isSliderEnd == true)
    {
        rangeSlider.lowerValue = Double(selectedVideo.lowerValue)
        rangeSlider.minimumValue = 0.0
        rangeSlider.maximumValue = Double(selectedVideo.seconds)
        rangeSlider.upperValue = Double(selectedVideo.upperValue)
      isSliderEnd = !isSliderEnd
    }

    startTimeLabel.text = "\(rangeSlider.lowerValue)"
    endTimeLabel.text   = "\(rangeSlider.upperValue)"
        self.selectedVideo?.lowerValue = rangeSlider.lowerValue
        self.selectedVideo?.upperValue = rangeSlider.upperValue
        
        if let selectedIndex = selectedIndex {
            if selectedIndex < Videos.count-1 {
                self.Videos[selectedIndex] = selectedVideo
            }
        }
        
    if(rangeSlider.lowerLayerSelected)
    {
      seekVideo(toPos: CGFloat(rangeSlider.lowerValue))
    }
    else
    {
      seekVideo(toPos: CGFloat(rangeSlider.upperValue))
    }

  }
       
    //MARK: - Main Editing Operations
    
    @objc func nextStep(){
        
        if Videos.isEmpty {
            displayAlert(message: "You need to choose videos first", title: "Video Editor", send: false)
            return
        }
        
        var trimmedVideoAssetArray : [AVAsset] = []

        
        for index in 0...Videos.count-1 {
            
            func time(_ operation: () throws -> ()) rethrows {
                try operation()
            }
            do {
                try time {
                    let maxLength         = "\(Videos[index].seconds)" as NSString
                    let startTime:CMTime = CMTimeMakeWithSeconds(Double(Videos[index].lowerValue),preferredTimescale: Int32(maxLength.length))
                    let endTime:CMTime = CMTimeMakeWithSeconds(Double(Videos[index].upperValue),preferredTimescale: Int32(maxLength.length))
                    let asset = Videos[index].asset
                    let trimmedAsset = try asset.assetByTrimming(startTime: startTime, endTime: endTime)
                    trimmedVideoAssetArray.append(trimmedAsset)
                }
            } catch let error {
                print(error)
            }
        }
        
        let lastAsset = mergeVideos(assets: trimmedVideoAssetArray)
        
        let thumbTime = lastAsset.duration
        let seconds = Int(CMTimeGetSeconds(thumbTime))
        let newVideo = Video(asset: lastAsset, thumbTime: thumbTime, seconds: seconds, lowerValue: 0, upperValue: Double(seconds))
        
        selectedVideo = newVideo
                
        if let x = selectedVideo {
            self.createRangeSlider()
            self.createImageFrames(asset: x.asset)
            self.setPlayerItems(avAsset: x.asset)
            Videos = []
            Videos.append(newVideo)
            collectionView?.isHidden = true
        }
        else {
            displayAlert(message: "Something went teribbly wrong", title: "Video Editor", send: false)
        }
        
        if nextStepButton.isSelected {
            nextStepButton.isHidden = true
            saveVideo()
        } else {
            nextStepButton.isSelected = true
            nextStepButton.setTitle("Save", for: .normal)
        }
    }
    
    func mergeVideos(assets: [AVAsset]) -> AVAsset {
        let mixComposition = AVMutableComposition.init()
        mixComposition.naturalSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        var timeRange: CMTimeRange!
        var insertTime = CMTime.zero

        let track = mixComposition.addMutableTrack(withMediaType: AVMediaType.video,
                                                preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        for k in 0..<assets.count {
            let videoAsset = assets[k]
            timeRange = CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration )
            do {
                try track?.insertTimeRange(timeRange, of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
                } catch let error as NSError {
                    print("error when adding video to mix \(error)")
                }
           insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        
       dump(mixComposition.tracks)
       
        return mixComposition
    }
    
    func saveVideo(){
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
        
        guard let asset = Videos.first?.asset
        else { self.displayAlert(message: "Something went terribly wrong", title: "Video Editor", send: false) ; return }
        
        guard let exporter = AVAssetExportSession( asset: asset, presetName: AVAssetExportPresetHighestQuality)
        else {print("son guardda öldüm"); return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        let composition = AVMutableVideoComposition.init(propertiesOf: asset)
        composition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        exporter.videoComposition = composition
        

        exporter.exportAsynchronously {
          DispatchQueue.main.async {
            self.exportDidFinish(exporter)
          }
        }
    }
    
    func exportDidFinish(_ session: AVAssetExportSession){
        guard
          session.status == AVAssetExportSession.Status.completed,
          let outputURL = session.outputURL
        else { return }

        let saveVideoToPhotos = {
        let changes: () -> Void = {
          PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
        }
        PHPhotoLibrary.shared().performChanges(changes) { saved, error in
          DispatchQueue.main.async {
            let success = saved && (error == nil)
            let title = success ? "Success" : "Error"
            let message = success ? "Video saved" : "Failed to save video"
            
              self.displayAlert(message: message, title: title, send: true)
          }
        }
    }
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
          PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
              saveVideoToPhotos()
            }
          }
        } else {
          saveVideoToPhotos()
        }
        
        
    }
    
    func displayAlert(message: String,title: String,send: Bool){
 
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
            let okButton = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
                if send {
                    self.performSegue(withIdentifier: "unwindToPlay", sender: self)
                }
            }
 
            alert.addAction(okButton)

            present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToPlay" {
            if let vc = segue.destination as? PlayViewController {
                vc.asset = self.Videos.first?.asset
            }
        }
    }
    
}



//MARK: - Extensions

extension AVMutableComposition {
    convenience init(asset: AVAsset) {
        self.init()
        
        for track in asset.tracks {
            addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
        }
    }
    
    func trim(startTime: CMTime, endTime: CMTime) {
        let duration = endTime - startTime
        let timeRange = CMTimeRange(start: startTime, duration: duration)
        
        for track in tracks {
            track.removeTimeRange(timeRange)
        }
        
        removeTimeRange(timeRange)
    }
}

extension AVAsset {
    func assetByTrimming(startTime: CMTime, endTime: CMTime) throws -> AVAsset {
        let duration = endTime - startTime
        let timeRange = CMTimeRange(start: startTime, duration: duration)

        let composition = AVMutableComposition()
        composition.naturalSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        do {
            for track in tracks {
                let compositionTrack = composition.addMutableTrack(withMediaType: track.mediaType, preferredTrackID: track.trackID)
                try compositionTrack?.insertTimeRange(timeRange, of: track, at: CMTime.zero)
            }
        } catch let error {
            throw TrimError("error during composition", underlyingError: error)
        }

        return composition
    }
    
}

//MARK: - Data Models

struct TrimError: Error {
    let description: String
    let underlyingError: Error?

    init(_ description: String, underlyingError: Error? = nil) {
        self.description = "TrimVideo: " + description
        self.underlyingError = underlyingError
    }
}

struct Video {
    var asset : AVAsset
    var thumbTime : CMTime
    var seconds : Int
    var lowerValue : Double
    var upperValue : Double
}
