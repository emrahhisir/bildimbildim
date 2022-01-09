//
//  PlayViewController.swift
//  Bildim Bildim
//
//  Created by Emrah Hisir on 12/19/14.
//  Copyright (c) 2014 Emrah Hisir. All rights reserved.
//

import Foundation
import CoreMotion
import AudioToolbox
import AVFoundation

var totalScores = [[Int]]()

class PlayViewController: GenericDetailViewController, MotionControllerProtocol, AVAudioPlayerDelegate, BBPopupViewDelegate {
    
    var questions: [CDQuestion] = [CDQuestion]()
    var questionIndex = 0
    var categoryTitle = ""
    var answeredQuestions = [[String:Bool]]()
    var detailVCManager: SplitVCRootViewController?
    let settingsProvider = SettingsProvider()
    var finishTime = 5
    var isContinuePlay = false
    var firstLoad = true
    var timer: NSTimer?
    var isPlayStarted = false
    var isPlayEnded = false
    var isPaused = false
    var backPopupView: BBPopupView?
    let musicCount:UInt32 = 2
    var teamNumber = 0
    var roundNumber = 0
    var teamIndex = 1
    var roundIndex = 1
    var currentTeamIndex = 0
    var currentRoundIndex = 0
    var statsURLRequest = NSMutableURLRequest(URL: NSURL(string: "http://bildimbildim.mobew.com/feedstats.php")!)
    var statsData = ""
    var previousAnsweredTime = 0
    let cameraEngine = CameraEngine.sharedInstance()
    
    var introMusic: AVAudioPlayer?
    var backgroundMusic: AVAudioPlayer?
    var countdownMusic: AVAudioPlayer?
    var playedMusic: AVAudioPlayer?
    var correctSoundObject: SystemSoundID = 0
    var passSoundObject: SystemSoundID = 0
    
    @IBOutlet weak var backPopupContainerView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var teamRoundLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isRoot = true
        statsURLRequest.timeoutInterval = 60
        statsURLRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        statsURLRequest.HTTPMethod = "POST"
    }
    
    override func viewDidLoad() {
        arrangeTeamRoundLabel()
        if (self.settingsProvider.soundOnOff[self.settingsProvider.settings["SoundOnOff"]!] == "On") {
            selectMusics()
        }
        super.viewDidLoad()
        if (settingsProvider.videoRecordOnOff[settingsProvider.settings["VideoRecordOnOff"]!] == "On") {
            startVideoPreview()
        }
        categoryNameLabel.text = categoryTitle
        self.motionController.delegate = self
        self.motionController.getGyroData(motionManager)
        self.view.backgroundColor = UIColor.blueColor()
        finTimeLabel.text = String(finishTime)
        loadElements()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeLeft
    }
    
    override func viewWillAppear(animated: Bool) {
        resumeMusic()
        isPaused = false
    }
    
    func pauseMusic() {
        if ((playedMusic?.playing) != nil) {
            playedMusic?.pause()
        }
        if ((countdownMusic?.playing) != nil) {
            countdownMusic?.pause()
        }
        if (settingsProvider.videoRecordOnOff[settingsProvider.settings["VideoRecordOnOff"]!] == "On") {
            cameraEngine.pauseCapture()
        }
    }
    
    func resumeMusic() {
        if (firstLoad == false && (playedMusic?.playing) != nil) {
            playedMusic?.play()
        }
        if (isPlayStarted && finishTime < 12 && ((countdownMusic?.playing) != nil)) {
            countdownMusic?.play()
        }
        if (settingsProvider.videoRecordOnOff[settingsProvider.settings["VideoRecordOnOff"]!] == "On") {
            cameraEngine.resumeCapture()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        pauseMusic()
        isPaused = true
        isContinuePlay = false
        if (isPlayStarted == false) {
            firstLoad = true
        }
        if let validTimer = timer {
            validTimer.invalidate()
        }
        backPopupView?.removeAnimate()
        backPopupView = nil
    }
    
    @IBOutlet var categoryNameLabel: UILabel!
    
    @IBOutlet var questionLabel: UILabel!
    
    @IBOutlet var finTimeLabel: UILabel!
    
    
    func selectMusics() {
        let selectedMusicIndex = arc4random_uniform(musicCount) + 1
        introMusic = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath : NSBundle.mainBundle().pathForResource("intro\(selectedMusicIndex)", ofType: "mp3")!), error: nil)
        backgroundMusic = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath : NSBundle.mainBundle().pathForResource("repeat\(selectedMusicIndex)", ofType: "mp3")!), error: nil)
        countdownMusic = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath : NSBundle.mainBundle().pathForResource("sound_countdown", ofType: "mp3")!), error: nil)
        
        introMusic?.prepareToPlay()
        backgroundMusic?.numberOfLoops = -1
        backgroundMusic?.prepareToPlay()
        introMusic?.delegate = self
        playedMusic = introMusic
        
        AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath : NSBundle.mainBundle().pathForResource("sound_correct", ofType: "mp3")!), &correctSoundObject)
        AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath : NSBundle.mainBundle().pathForResource("sound_pass", ofType: "wav")!), &passSoundObject)
    }
    
    func arrangeTeamRoundLabel() -> Bool {
        var result = false
        
        currentTeamIndex = teamIndex
        currentRoundIndex = roundIndex
        
        if (teamNumber == 0) {
            teamRoundLabel.text = ""
            result = false
        }
        else if (firstLoad) {
            let teamLocalName = NSLocalizedString("Team", comment: "team")
            let roundLocalName = NSLocalizedString("Round", comment: "round")
            teamRoundLabel.text = "\(roundLocalName)\(roundIndex)/\(teamLocalName)\(teamIndex)"
            
            for _ in 0...(roundNumber - 1) {
                totalScores.append(Array(count: teamNumber, repeatedValue: 0))
            }
        }
        else {
            if (roundIndex < roundNumber) {
                if (teamIndex < teamNumber) {
                    teamIndex = teamIndex + 1
                    result = true
                }
                else {
                    roundIndex = roundIndex + 1
                    teamIndex = 1
                    result = true
                }
            }
            else if (teamIndex < teamNumber) {
                teamIndex = teamIndex + 1
                result = true
            }
            else {
                result = false
            }
            let teamLocalName = NSLocalizedString("Team", comment: "team")
            let roundLocalName = NSLocalizedString("Round", comment: "round")
            teamRoundLabel.text = "\(roundLocalName)\(roundIndex)/\(teamLocalName)\(teamIndex)"
        }
        
        return result
    }
    
    func loadElements() {
        firstLoad = true
        finishTime = 5
        questionLabel.text = NSLocalizedString("PlayIntroTitle", comment: "PlayIntro")
        answeredQuestions = [[String:Bool]]()
        
    }
    
    let motionManager = CMMotionManager()
    let motionController = MotionController()
    
    func getMotionData(roll:Double) { //oyunun ana akisi burada
        
        //0.5ten küçük olunca pass 2.5ten büyük olunca correct olacak
        let z = abs(roll)
        
        if (isPaused == false) {
            if isContinuePlay == false {
                if 2.0>z && z>1.0 { //cihaz dik konumda oyun baslatma
                    if (firstLoad) {
                        playedMusic?.play()
                        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "stopWatch5Sec", userInfo: nil, repeats: true) //ekran dogru konumda ise 5 saniye icinde baslayacak
                        firstLoad = false
                    }
                    else if (isPlayStarted && isPlayEnded == false) {
                        self.questionLabel.text = removeWhiteSpaceCharacters(questions[questionIndex].question)
                        if (timer?.valid == false) {
                            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "stopWatch", userInfo: nil, repeats: true)
                        }
                        isContinuePlay = true
                    }
                }
                else if (isPlayStarted){
                    if let validTimer = timer {
                        validTimer.invalidate()
                    }
                    self.view.backgroundColor = UIColor.blueColor()
                    self.questionLabel.text = NSLocalizedString("PlayError", comment: "PlayError")
                }
            }
            else if (isPlayStarted){
                //println(z)
                if z < 1.0 && z > 0.1 {
                    newQuestion("pass")
                }
                else if z > 2.0 && z < 2.9 {
                    newQuestion("correct")
                }
                else if z > 2.9 || z < 0.1 {
                    if let validTimer = timer {
                        validTimer.invalidate()
                    }
                    isContinuePlay = false
                    self.view.backgroundColor = UIColor.blueColor()
                    self.questionLabel.text = NSLocalizedString("PlayError", comment: "PlayError")
                }
            }
        }
    }
    
    func newQuestion(reason: String) {
        
        isPaused = true
        isContinuePlay = false
        /*if let validTimer = timer {
            validTimer.invalidate()
        }*/
        
        let questionObject = questions[questionIndex++]
        if (questionIndex == questions.count) {
            finishTime = 0
            isPaused = false
            stopWatch()
            return
        }
        let question = removeWhiteSpaceCharacters(questionObject.question)
        //finTimeLabel.text = ""
        
        switch reason {
        case "correct":
            appendStatsData(questionObject.id.integerValue, answerType: "correct", answerTime: previousAnsweredTime -  finishTime)
            answeredQuestions.append([question:true])
            view.backgroundColor = UIColor.greenColor()
            questionLabel.text = NSLocalizedString("CorrectAnswer", comment: "Correct Answer")
            playSound("bip")
            if (self.settingsProvider.bonusTimeOnOff[self.settingsProvider.settings["BonusTimeOnOff"]!] == "On") {
                finishTime = finishTime + 2
            }
        case "pass":
            appendStatsData(questionObject.id.integerValue, answerType: "pass", answerTime: previousAnsweredTime -  finishTime)
            answeredQuestions.append([question:false])
            view.backgroundColor = UIColor.redColor()
            questionLabel.text = NSLocalizedString("PassAnswer", comment: "Pass Answer")
            playSound("biip")
        default:
            break
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.view.backgroundColor = UIColor.blueColor()
            self.questionLabel.text = self.removeWhiteSpaceCharacters(self.questions[self.questionIndex].question)
            //self.finTimeLabel.text = "\(self.finishTime)"
            self.isPaused = false
        }
    }

    func removeWhiteSpaceCharacters(token: String) -> String {
        var result = token.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        result = result.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        return result
    }
    
    func stopWatch() { //input olarak sure miktari alinacak
        if (finishTime > 0) {
            finishTime--
        }
        
        if (finishTime == 11) {
            playSound("countdown")
        }
        else if (finishTime <= 0 && isPaused == false) {// sure bitince sonuclari ekrana getir
            
            if let validTimer = timer {
                validTimer.invalidate()
            }
            isPaused = true
            isContinuePlay = false
            isPlayStarted = false
            playSound("timeUp")
            
            sendStats()
            if (settingsProvider.videoRecordOnOff[settingsProvider.settings["VideoRecordOnOff"]!] == "On") {
                cameraEngine.stopCapture()
            }
            
            if (arrangeTeamRoundLabel()) {
                questionIndex++
                let newViewController = ResultViewController(nibName: "Result", bundle: nil)
                newViewController.awakeFromNib()
                newViewController.isSoundOn = settingsProvider.soundOnOff[self.settingsProvider.settings["SoundOnOff"]!] == "On"
                for answer in answeredQuestions {
                    let key = [String](answer.keys)
                    newViewController.keyOfAnswers.append(key[0])
                    newViewController.valueOfAnswers.append(answer[key[0]]!)
                }
                newViewController.teamIndex = currentTeamIndex - 1
                newViewController.roundIndex = currentRoundIndex - 1
                answeredQuestions.removeAll(keepCapacity: false)
                loadElements()
                setDetailViewController(newViewController)
            }
            else {
                isPlayEnded = true
                
                let newViewController = ResultViewController(nibName: "Result", bundle: nil)
                newViewController.awakeFromNib()
                newViewController.isSoundOn = settingsProvider.soundOnOff[self.settingsProvider.settings["SoundOnOff"]!] == "On"
                for answer in answeredQuestions {
                    let key = [String](answer.keys)
                    newViewController.keyOfAnswers.append(key[0])
                    newViewController.valueOfAnswers.append(answer[key[0]]!)
                }
                if (teamNumber > 0) {
                    newViewController.isFinished = true
                    newViewController.teamIndex = currentTeamIndex - 1
                    newViewController.roundIndex = currentRoundIndex - 1
                }
                setDetailViewController(newViewController)
            }
            
        }
        
        finTimeLabel.text = "\(finishTime)"
    }
    
    func stopWatch5Sec() {
        finishTime--
        
        if (finishTime <=  0) {
            
            if let validTimer = timer {
                validTimer.invalidate()
            }
            isPlayStarted = true
            self.questionLabel.text = self.questions[self.questionIndex].question
            self.finishTime = self.settingsProvider.roundTimes[self.settingsProvider.settings["RoundTime"]!]
            self.previousAnsweredTime = self.finishTime
            self.finTimeLabel.text = String(self.finishTime)
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "stopWatch", userInfo: nil, repeats: true) //ilk soru alininca bu sefer 90dan geri sayacak
            self.isContinuePlay = true
            if (settingsProvider.videoRecordOnOff[settingsProvider.settings["VideoRecordOnOff"]!] == "On") {
                cameraEngine.startCapture()
            }
        }
        
        finTimeLabel.text = "\(finishTime)"
    }
    
    func playSound(soundType: String) {
        
        if (self.settingsProvider.soundOnOff[self.settingsProvider.settings["SoundOnOff"]!] == "On") {
            switch soundType {
                case "bip":
                    // play bip
                    //AudioServicesPlaySystemSound(1054)
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    AudioServicesPlaySystemSound(correctSoundObject)
                case "biip":
                    // play biip
                    //AudioServicesPlaySystemSound(1057)
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    AudioServicesPlaySystemSound(passSoundObject)
                case "countdown":
                    countdownMusic?.play()
                case "timeup":
                     AudioServicesPlaySystemSound(1056)
                case "backgroundMusic":
                    if (playedMusic?.playing == false) {
                        playedMusic = backgroundMusic
                        playedMusic?.play()
                    }
                default:
                    break
            }
        }
        else {
            switch soundType {
            case "bip", "biip":
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            default:
                break
            }
        }
    }
    
    func setDetailViewController(detailVC: GenericDetailViewController) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        detailVCManager?.setGenericDetailViewController(detailVC)
    }
    
    func popToTopViewController(animated: Bool) {
        if (detailVCManager == nil) {
            detailVCManager = self.navigationController?.parentViewController?.parentViewController as! SplitVCRootViewController?
        }
        motionController.delegate = nil
        backgroundMusic?.stop()
        backgroundMusic = nil
        if let validTimer = timer {
            validTimer.invalidate()
        }
        timer = nil
        detailVCManager?.popToTopViewControllerWithSidebar(animated)
    }
    
    @IBAction func pressedBack(sender: UIButton) {
        pauseMusic()
        isPaused = true
        isContinuePlay = false
        if (isPlayStarted == false) {
            firstLoad = true
        }
        if let validTimer = timer {
            validTimer.invalidate()
        }
        
        let tempViews = NSBundle.mainBundle().loadNibNamed("Back", owner: self, options: nil)
        backPopupView = tempViews[0] as? BBPopupView
        backPopupView?.setContent(backPopupContainerView, continueButton: continueButton, ownerViewController: self)
        endButton.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.75)
        backPopupView?.showInView(self.view, animated: true)
    }
    
    @IBAction func pressedEndPlay(sender: AnyObject) {
        backPopupView?.removeAnimate()
        backPopupView = nil
        popToTopViewController(true)
    }
    
    @IBAction func pressedContinuePlay(sender: AnyObject) {
        resumeMusic()
        backPopupView?.removeAnimate()
        backPopupView = nil
        isPaused = false
    }
    
    override func removePopupView() {
        backPopupView = nil
        isPaused = false
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        playSound("backgroundMusic")
    }
    
    func appendStatsData(id:Int, answerType: String, answerTime: Int) {
        previousAnsweredTime = finishTime
        statsData = statsData + "{\"id\":\(id), \"status\":\"\(answerType)\", \"time\":\(answerTime)},"
    }
    
    func createPostData() -> NSData {
        var result = NSData()
        
        if (statsData.isEmpty == false) {
            result = ("stats={\"questions\":[" + statsData.substringToIndex(advance(statsData.startIndex, count(statsData) - 1)) + "]}").dataUsingEncoding(NSUTF8StringEncoding)!
            statsData = ""
        }
        
        return result
    }
    
    func sendStats() {
        let postData = createPostData()
        if (postData.length > 0) {
            statsURLRequest.HTTPBody = postData
            let queue:NSOperationQueue = NSOperationQueue()
        
            NSURLConnection.sendAsynchronousRequest(statsURLRequest, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            })
            //NSURLConnection(request: statsURLRequest, delegate: self, startImmediately: true)
        }
    }
    
    // MARK: Video Capturing
    
    func startVideoPreview() {
        let preview: AVCaptureVideoPreviewLayer = cameraEngine.getPreviewLayer()
        preview.removeFromSuperlayer()
        let cameraFrame = CGRectMake(0.0, 0.0, self.view.bounds.width*10/7, self.view.bounds.height)
        preview.frame = UIScreen.mainScreen().bounds
        preview.opacity = 0.3
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        switch(orientation) {
        case .Portrait:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        case .PortraitUpsideDown:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
        case .LandscapeLeft:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        case .LandscapeRight:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        default:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        }
        
        self.view.layer.addSublayer(preview)
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let preview: AVCaptureVideoPreviewLayer = cameraEngine.getPreviewLayer()
        switch(toInterfaceOrientation) {
        case .Portrait:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        case .PortraitUpsideDown:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
        case .LandscapeLeft:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        case .LandscapeRight:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
        default:
            preview.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        }
    }
}