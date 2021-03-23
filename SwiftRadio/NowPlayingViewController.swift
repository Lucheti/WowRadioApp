//
//  NowPlayingViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/22/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit


//*****************************************************************
// NowPlayingViewControllerDelegate
//*****************************************************************

protocol NowPlayingViewControllerDelegate: class {
    func didPressPlayingButton()
    func didPressStopButton()
    func didPressNextButton()
    func didPressPreviousButton()
}

//*****************************************************************
// NowPlayingViewController
//*****************************************************************

class NowPlayingViewController: UIViewController {
    
    weak var delegate: NowPlayingViewControllerDelegate?

    // MARK: - IB UI
    
    @IBOutlet weak var albumHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumImageView: SpringImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playingButton: UIButton!
    @IBOutlet weak var songLabel: SpringLabel!
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var volumeParentView: UIView!
    @IBOutlet weak var background: UIImageView!
    
    // MARK: - Properties
    
    var currentStation: RadioStation!
    var currentTrack: Track!
    
    var newStation = true
    var nowPlayingImageView: UIImageView!
    let radioPlayer = FRadioPlayer.shared
    
    var mpVolumeSlider: UISlider?
    var currentGifIndex: Int = 3

    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create Now Playing BarItem
        createNowPlayingAnimation()
        
        // Set AlbumArtwork Constraints
        optimizeForDeviceSize()

        // Set View Title
        self.title = currentStation.name
        
        // Set UI
        albumImageView.image = currentTrack.artworkImage
        stationDescLabel.text = currentStation.desc
        stationDescLabel.isHidden = currentTrack.artworkLoaded
        
        // Check for station change
        newStation ? stationDidChange() : playerStateDidChange(radioPlayer.state, animate: false)
        
        // Setup volumeSlider
        setupVolumeSlider()
        
        //Setup background gif
        changeBackgroundGif()
        
        //Setup on background mode event handler
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let jeremyGif = UIImage.gifImageWithName("fondo0")

        background.image = jeremyGif
    }

    @objc func appMovedToBackground() {
        changeBackgroundGif()
    }
    
    //*****************************************************************
    // MARK: - Apply gif
    //*****************************************************************
    
    func changeBackgroundGif() {
        let queue = DispatchQueue.global(qos: .utility)
        let backgroundId = "fondo\(String(describing: self.nextGifIndex(i: self.currentGifIndex)))"
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`")
        print(backgroundId)
        queue.async { [weak self] in
            guard let jeremyGif = UIImage.gifImageWithName(backgroundId) else { return }
            
            DispatchQueue.main.async {
                self?.currentGifIndex += 1
                self?.background.image = jeremyGif
            }
        }
    }
    
    func nextGifIndex(i: Int) -> Int {
        return i % 3
    }
    
    //*****************************************************************
    // MARK: - Setup
    //*****************************************************************
    
    func setupVolumeSlider() {
        // Note: This slider implementation uses a MPVolumeView
        // The volume slider only works in devices, not the simulator.
        for subview in MPVolumeView().subviews {
            guard let volumeSlider = subview as? UISlider else { continue }
            mpVolumeSlider = volumeSlider
        }
        
        guard let mpVolumeSlider = mpVolumeSlider else { return }
        
        volumeParentView.addSubview(mpVolumeSlider)
        
        mpVolumeSlider.translatesAutoresizingMaskIntoConstraints = false
        mpVolumeSlider.leftAnchor.constraint(equalTo: volumeParentView.leftAnchor).isActive = true
        mpVolumeSlider.rightAnchor.constraint(equalTo: volumeParentView.rightAnchor).isActive = true
        mpVolumeSlider.centerYAnchor.constraint(equalTo: volumeParentView.centerYAnchor).isActive = true
        
        mpVolumeSlider.setThumbImage(#imageLiteral(resourceName: "slider-ball"), for: .normal)
    }

    
    func stationDidChange() {
        radioPlayer.radioURL = URL(string: currentStation.streamURL)
        albumImageView.image = currentTrack.artworkImage
        stationDescLabel.text = currentStation.desc
        stationDescLabel.isHidden = currentTrack.artworkLoaded
        title = currentStation.name
    }
    
    //*****************************************************************
    // MARK: - Player Controls (Play/Pause/Volume)
    //*****************************************************************
    
    // Actions
    
    @IBAction func playingPressed(_ sender: Any) {
        delegate?.didPressPlayingButton()
    }
    
    @IBAction func stopPressed(_ sender: Any) {
        delegate?.didPressStopButton()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        delegate?.didPressNextButton()
    }
    
    @IBAction func previousPressed(_ sender: Any) {
        delegate?.didPressPreviousButton()
    }
    
    //*****************************************************************
    // MARK: - Social media Nav (Facebook/Instagram/Web)
    //*****************************************************************
    
    //social media navigations

    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        navigate(url: "http://www.wowrradio.com.au/")
    }

    @IBAction func facebookButtonPressed(_ sender: Any) {
        navigate(url: "https://www.facebook.com/wowradio.go/")
    }

    @IBAction func instagramButtonPressed(_ sender: Any) {
        navigate(url: "https://instagram.com/woowfm?igshid=1bat8hj6n5u36")
    }


    func navigate(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    //*****************************************************************
    // MARK: - Load station/track
    //*****************************************************************
    
    func load(station: RadioStation?, track: Track?, isNewStation: Bool = true) {
        guard let station = station else { return }
        
        currentStation = station
        currentTrack = track
        newStation = isNewStation
    }
    
    func updateTrackMetadata(with track: Track?) {
        guard let track = track else { return }
        
        currentTrack.artist = track.artist
        currentTrack.title = track.title
        
        updateLabels()
    }
    
    // Update track with new artwork
    func updateTrackArtwork(with track: Track?) {
        guard let track = track else { return }
        
        // Update track struct
        currentTrack.artworkImage = track.artworkImage
        currentTrack.artworkLoaded = track.artworkLoaded
        
        albumImageView.image = currentTrack.artworkImage
        
        if track.artworkLoaded {
            // Animate artwork
            albumImageView.animation = "wobble"
            albumImageView.duration = 2
            albumImageView.animate()
            stationDescLabel.isHidden = true
        } else {
            stationDescLabel.isHidden = false
        }
        
        // Force app to update display
        view.setNeedsDisplay()
    }
    
    private func isPlayingDidChange(_ isPlaying: Bool) {
        playingButton.isSelected = isPlaying
        startNowPlayingAnimation(isPlaying)
    }
    
    func playbackStateDidChange(_ playbackState: FRadioPlaybackState, animate: Bool) {
        
        let message: String?
        
        switch playbackState {
        case .paused:
            message = "Station Paused..."
        case .playing:
            message = nil
        case .stopped:
            message = "Station Stopped..."
        }
        
        updateLabels(with: message, animate: animate)
        isPlayingDidChange(radioPlayer.isPlaying)
    }
    
    func playerStateDidChange(_ state: FRadioPlayerState, animate: Bool) {
        
        let message: String?
        
        switch state {
        case .loading:
            message = "Loading Station ..."
        case .urlNotSet:
            message = "Station URL not valid"
        case .readyToPlay, .loadingFinished:
            playbackStateDidChange(radioPlayer.playbackState, animate: animate)
            return
        case .error:
            message = "Error Playing"
        }
        
        updateLabels(with: message, animate: animate)
    }
    
    //*****************************************************************
    // MARK: - UI Helper Methods
    //*****************************************************************
    
    func optimizeForDeviceSize() {
        
        // Adjust album size to fit iPhone 4s, 6s & 6s+
        let deviceHeight = self.view.bounds.height
        
        if deviceHeight == 480 {
            albumHeightConstraint.constant = 106
            view.updateConstraints()
        } else if deviceHeight == 667 {
            albumHeightConstraint.constant = 230
            view.updateConstraints()
        } else if deviceHeight > 667 {
            albumHeightConstraint.constant = 260
            view.updateConstraints()
        }
    }
    
    func updateLabels(with statusMessage: String? = nil, animate: Bool = true) {

        guard let statusMessage = statusMessage else {
            // Radio is (hopefully) streaming properly
            songLabel.text = currentTrack.title
            artistLabel.text = currentTrack.artist
            shouldAnimateSongLabel(animate)
            return
        }
        
        // There's a an interruption or pause in the audio queue
        
        // Update UI only when it's not aleary updated
        guard songLabel.text != statusMessage else { return }
        
        songLabel.text = statusMessage
        artistLabel.text = currentStation.name
    
        if animate {
            songLabel.animation = "flash"
            songLabel.repeatCount = 3
            songLabel.animate()
        }
    }
    
    // Animations
    
    func shouldAnimateSongLabel(_ animate: Bool) {
        // Animate if the Track has album metadata
        guard animate, currentTrack.title != currentStation.name else { return }
        
        // songLabel animation
        songLabel.animation = "zoomIn"
        songLabel.duration = 1.5
        songLabel.damping = 1
        songLabel.animate()
    }
    
    func createNowPlayingAnimation() {
        
        // Setup ImageView
        nowPlayingImageView = UIImageView(image: UIImage(named: "NowPlayingBars-3"))
        nowPlayingImageView.autoresizingMask = []
        nowPlayingImageView.contentMode = UIView.ContentMode.center
        
        // Create Animation
        nowPlayingImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingImageView.animationDuration = 0.7
        
        // Create Top BarButton
        let barButton = UIButton(type: .custom)
        barButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        barButton.addSubview(nowPlayingImageView)
        nowPlayingImageView.center = barButton.center
        
        let barItem = UIBarButtonItem(customView: barButton)
        self.navigationItem.rightBarButtonItem = barItem
    }
    
    func startNowPlayingAnimation(_ animate: Bool) {
        animate ? nowPlayingImageView.startAnimating() : nowPlayingImageView.stopAnimating()
    }
    
    //*****************************************************************
    // MARK: - Segue
    //*****************************************************************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "InfoDetail", let infoController = segue.destination as? InfoDetailViewController else { return }
        infoController.currentStation = currentStation
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "InfoDetail", sender: self)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        let radioShoutout = "I'm listening to \(currentStation.name) via Swift Radio Pro"
        let shareImage = ShareImageGenerator(radioShoutout: radioShoutout, track: currentTrack).generate()
        
        let activityViewController = UIActivityViewController(activityItems: [radioShoutout, shareImage], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
        activityViewController.popoverPresentationController?.sourceView = view
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                // do something on completion if you want
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
}

// code to load a gif
//
//  iOSDevCenters+GIF.swift
//  GIF-Swift
//
//  Created by iOSDevCenters on 11/12/15.
//  Copyright © 2016 iOSDevCenters. All rights reserved.
//
import UIKit
import ImageIO
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)
        
        return animation
    }
    
}


