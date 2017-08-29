//
//  ViewController.swift
//  Lab2
//
//  Created by Alexander on 2017/1/31.
//  Copyright © 2017年 Zheng Yuan. All rights reserved.
//

import UIKit
import SwiftGif
import CoreMotion
import AudioToolbox
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    private var animator: UIDynamicAnimator!
    private let gravityBehavior = UIGravityBehavior()
    private let collisionBehavior = UICollisionBehavior()
//    private let tapGR = UITapGestureRecognizer()
    private let doubleTap = UITapGestureRecognizer()
    private let motionManager = CMMotionManager()
    
   
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var happyLabel: UILabel!
    @IBOutlet weak var fedLabel: UILabel!
    @IBOutlet weak var happyView: DisplayView!
    @IBOutlet weak var feedView: DisplayView!
    
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var petView: UIImageView!
    
    var foodArray:[UIImageView] = []
    var playArray:[UIImageView] = []
    var petBear:pet!
    var petDog:pet!
    var petGuinea:pet!
    var petFrog:pet!
    var petDuck:pet!
    var mainPet:pet!
    var foodSound:SystemSoundID = 0
    var playShortSound:SystemSoundID = 0
    var tempR:Int = 0
    var cold:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tapGR.addTarget(self, action: #selector(ViewController.tapped))
//        mainView.addGestureRecognizer(tapGR)
        
        
        
        animator = UIDynamicAnimator(referenceView: mainView)
        
        gravityBehavior.gravityDirection = CGVector(dx: 0, dy: 1)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        
        doubleTap.addTarget(self, action: #selector(DoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        
        mainView.addGestureRecognizer(doubleTap)
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(collisionBehavior)
        
        foodSound = createSound(inputName: "eat", inputType: "wav")
        playShortSound = createSound(inputName: "playShort", inputType: "aif")
        
        activateTheGravity()
        petBear = pet(name:.bear, color: UIColor.darkGray )
        petDog = pet(name: .dog, color: UIColor.brown)
        petDuck = pet(name: .duck, color: UIColor.yellow)
        petFrog = pet(name: .frog, color: UIColor.green)
        petGuinea = pet(name: .guinea, color: UIColor.lightGray)
        mainPet = petDog
        loadJsonData()
        loadDatabase()
        update(updateType: "animate")
        
    }

    func activateTheGravity() {
        
        if motionManager.isAccelerometerAvailable {
            
            motionManager.accelerometerUpdateInterval = 0.25
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                
                guard var dx = data?.acceleration.x else { return }
                guard var dy = data?.acceleration.y else { return }
                
                switch UIDevice.current.orientation {
                case .portrait: dy = -dy
                case .portraitUpsideDown: break
                case .landscapeRight: swap(&dx, &dy)
                case .landscapeLeft: swap(&dx, &dy); dy = -dy
                default: dx = 0; dy = 0
                }
                
                self.gravityBehavior.gravityDirection = CGVector(dx: dx, dy: dy)
                
            }
        }
        
    }

    
    @IBAction func playButton(_ sender: UIButton) {
        let randx = arc4random_uniform(200)
        let randy = arc4random_uniform(200)
        let theView = UIImageView(frame: CGRect(x: Int(randx), y: Int(randy), width: 30, height: 30))
        let playid = arc4random_uniform(6)+1
        theView.image = UIImage(named: "play"+String(playid))
        print("array size= ",playArray.count)
        if playArray.count < 15 {
            theView.tag = 200
            mainView.addSubview(theView)
            playArray.append(theView)
            collisionBehavior.addItem(theView)
        }
        UIView.animate(withDuration: 1, animations: {
            theView.transform = CGAffineTransform(scaleX: 5, y: 5)
        }) { (finished) in
            UIView.animate(withDuration: 1, animations: {
                theView.transform = CGAffineTransform.identity
            })
        }
        
    }
    
    func haveFun() {
        if(mainPet.play(Cold: cold) == true){
            let when = DispatchTime.now() + 0.5
            self.petView.image = self.mainPet.playImage
            DispatchQueue.main.asyncAfter(deadline: when){
                self.update(updateType: "animate")
                AudioServicesPlaySystemSound(self.playShortSound)
            }
        }
    }
    
    @IBAction func feedButton(_ sender: UIButton) {
        tapped()
    }
    
    func eatFood(){
        if(mainPet.feed() == true){
            let when = DispatchTime.now() + 0.5
            self.petView.image = self.mainPet.feedImage
            DispatchQueue.main.asyncAfter(deadline: when){
                self.update(updateType: "animate")
                AudioServicesPlaySystemSound(self.foodSound)
            }
            
        }
    }
    
    
    func update(updateType:String){
        petView.image = mainPet.petImageUpdate()
        foodImageView.image = mainPet.foodIcon
        gameImageView.image = mainPet.playIcon
        gameImageView.alpha = mainPet.playIconUpdate()
        foodImageView.alpha = mainPet.foodIconUpdate()
        mainView.backgroundColor = mainPet.petColor
        happyView.color = mainPet.petColor
        feedView.color = mainPet.petColor
        happyLabel.text = "played: "+String(mainPet.playedTimes)
        fedLabel.text = "fed: "+String(mainPet.fedTimes)
        let ud = UserDefaults(suiteName: "group.Lab2.MyLocation")
        ud!.set(12313, forKey: "test")
        ud!.set(mainPet.happiness, forKey: "happy")
        ud!.set(mainPet.foodLevel, forKey: "food")
        ud!.set(mainPet.petName.rawValue, forKey:"petName")
        updateDatabase()
        switch updateType {
        case "noAnimate":
            happyView.value = mainPet.happyValue
            feedView.value = mainPet.foodValue
        case "animate":
            happyView.animateValue(to: mainPet.happyValue)
            feedView.animateValue(to: mainPet.foodValue)
        default:
            happyView.animateValue(to: mainPet.happyValue)
            feedView.animateValue(to: mainPet.foodValue)
        }
        
        

    }
    
    @IBAction func dogButton(_ sender: UIButton) {
        mainPet = petDog
        petView.center = mainView.center
        loadDatabase()
        update(updateType: "noAnimate")
        removeFoodAndPlay()
    }
    
    @IBAction func bearButton(_ sender: UIButton) {
        mainPet = petBear
        petView.center = mainView.center
        loadDatabase()
        update(updateType: "noAnimate")
        removeFoodAndPlay()
    }
    
    @IBAction func duckButton(_ sender: UIButton) {
        mainPet = petDuck
        petView.center = mainView.center
        loadDatabase()
        update(updateType: "noAnimate")
        removeFoodAndPlay()
    }
    
    @IBAction func guineaButton(_ sender: UIButton) {
        mainPet = petGuinea
        petView.center = mainView.center
        loadDatabase()
        update(updateType: "noAnimate")
        removeFoodAndPlay()
    }
    
    @IBAction func frogButton(_ sender: UIButton) {
        mainPet = petFrog
        petView.center = mainView.center
        loadDatabase()
        update(updateType: "noAnimate")
        removeFoodAndPlay()
    }
    
    func removeFoodAndPlay(){
        for theSubView in mainView.subviews{
                print(theSubView.tag)
                if(theSubView.tag == 200){
                    if(true){
                        theSubView.removeFromSuperview()
                        collisionBehavior.removeItem(theSubView)
                        playArray.remove(at: 0)
                    }
                }
                if(theSubView.tag == 100){
                    if(true){
                        theSubView.removeFromSuperview()
                        gravityBehavior.removeItem(theSubView)
                        collisionBehavior.removeItem(theSubView)
                        foodArray.remove(at: 0)
                    }
                }
            
        }
    }
    
    func tapped() {
        let randx = arc4random_uniform(200)
        let theView = UIImageView(frame: CGRect(x: Int(randx), y: 0, width: 30, height: 30))
        let foodid = arc4random_uniform(8)+1
        theView.image = UIImage(named: "food"+String(foodid))
        print("array size= ",foodArray.count)
        if foodArray.count < 15 {
            theView.tag = 100
            mainView.addSubview(theView)
            foodArray.append(theView)
            gravityBehavior.addItem(theView)
            collisionBehavior.addItem(theView)
        }
    }
    
//    func boundLayerPos(aNewPosition: CGPoint) -> CGPoint {
//        let winSize = petView.frame.size
//        var retval = aNewPosition
//        retval.x = CGFloat(min(retval.x, 0))
//        retval.x = CGFloat(max(retval.x, -(petView.frame.size.width) + winSize.width))
//        
//        return retval
//    }
    
    func inTouch(location: CGPoint) -> Bool {
        let tx = location.x
        let ty = location.y
        let px = petView.center.x
        let py = petView.center.y
        let xDist = tx - px
        let yDist = ty - py
        let dist = CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
        if dist < 40{
            return true
        }
        return false
    }
    
    func panForTranslation(translation: CGPoint) {
        let position = petView.center
        let aNewPositionPet = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
//        petView.center = self.boundLayerPos(aNewPosition: aNewPosition)
        petView.center = aNewPositionPet
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let positionInScene = touch?.location(in: mainView)
        let previousPosition = touch?.previousLocation(in: mainView)
        let translation = CGPoint(x: (positionInScene?.x)! - (previousPosition?.x)!, y: (positionInScene?.y)! - (previousPosition?.y)!)
        
        if abs((positionInScene?.x)!-mainView.center.x) < 200 && abs((positionInScene?.y)!-mainView.center.y) < 180{
            if(inTouch(location: (touch?.location(in: mainView))!)){
                panForTranslation(translation: translation)
            }
            eatHelper()
            playHelper()
        }
    }
    
    func eatHelper(){
        for theSubView in mainView.subviews{
            if(distance(px: petView.center, py: theSubView.center)<20){
                if(theSubView.tag == 100){
                    theSubView.removeFromSuperview()
                    gravityBehavior.removeItem(theSubView)
                    collisionBehavior.removeItem(theSubView)
                    foodArray.remove(at: 0)
                    eatFood()
                }
            }
        }
    }
    
    func playHelper(){
        for theSubView in mainView.subviews{
            if(distance(px: petView.center, py: theSubView.center)<20){
                if(theSubView.tag == 200){
                        if(mainPet.foodLevel>0){
                        theSubView.removeFromSuperview()
                        collisionBehavior.removeItem(theSubView)
                        playArray.remove(at: 0)
                        haveFun()
                    }
                }
            }
        }
    }
    
    func loadJsonData(){

        let urlOmdb:String = "http://api.openweathermap.org/data/2.5/weather?id=4407066&APPID=981062588c88beb1a9ab352865cd9979"
        var weatherDatas:JSON = getJSON(path: urlOmdb)
        
        let posterJSON = weatherDatas["weather"][0]["main"].string
        let weatherView = UIImageView(frame: CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.height))
        let clouds = weatherDatas["clouds"]["all"].int
        if (clouds! < 10){
            weatherImage.image = UIImage(named: "sunny.png")
            weatherView.image = UIImage.gif(name: "sunny")
        } else if(posterJSON?.contains("Rain"))! {
            weatherImage.image = UIImage(named: "rainLow.png")
            weatherView.image = UIImage.gif(name: "lowRain")
        } else if(posterJSON?.contains("Snow"))! {
            weatherImage.image = UIImage(named: "snow.png")
            weatherView.image = UIImage.gif(name: "snowy")
        } else if(posterJSON?.contains("Clouds"))! {
            weatherImage.image = UIImage(named: "cloudy.png")
            weatherView.image = UIImage.gif(name: "cloudy")
        } else if(posterJSON?.contains("thunderstorms"))!{
            weatherImage.image = UIImage(named: "Thunder.png")
            weatherView.image = UIImage.gif(name: "thunder")
        } else {
            weatherImage.image = UIImage(named: "sunny.png")
            weatherView.image = UIImage.gif(name: "sunny")
        }

        print("background:",mainView.frame.width,mainView.frame.height)
        print("weatherView:",weatherView.frame.width,weatherView.frame.height)
        weatherView.center.x = mainView.center.x
        weatherView.center.y = mainView.center.y-20
        mainView.insertSubview(weatherView, at: 0)
        let tempArr = weatherDatas["main"]["temp"].double
        let temp = tempArr!-273.5
        tempLabel.text = String(temp)+"°C"
        if temp < 10{
            cold = true
        }else{
            cold = false
        }
    }
    
    private func getJSON(path:String) -> JSON{
        guard let url = URL(string: path) else{ return JSON.null}
        //print(url)
        do {
            let data = try Data(contentsOf: url)
            return JSON(data: data)
        } catch {
            return JSON.null
        }
    }
    
    
    func createSound(inputName: String, inputType: String) -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), inputName as CFString!, inputType as CFString!, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        return soundID
    }
    
    
    func distance(px: CGPoint, py:CGPoint) -> Double{
        return sqrt(Double(pow(px.x-py.x, 2))+Double(pow(px.y-py.y,2)))
    }
    
    func DoubleTapped(touch: UITapGestureRecognizer){
        print("double tapped!  ",touch.location(in: mainView))
        let touchPoint = touch.location(in: mainView)
        if(self.mainPet.play(Cold: cold) == true){
            UIView.animate(withDuration: 2, delay: 0.0, usingSpringWithDamping:0.8, initialSpringVelocity: 1 , animations: {
                self.petView.center = touchPoint
            }, completion: {_ in
                self.eatHelper()
                self.playHelper()
                print("done")
            })
            self.update(updateType: "animate")
        }
    }
    
    func loadDatabase(){
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let thePath = delegate.PetDbPathInDocument
        let contactDB = FMDatabase(path: thePath)
        print("!!!!!!!!!!!!!!!!!!!!!!!!!! I am in loadDatabase path = ",thePath)
        if !(contactDB?.open())!{
            print("Unable to open db")
            return
        } else {
            do {
                let results = try contactDB?.executeQuery("select * from pet where petName=?", values: ["\(mainPet.petName.rawValue)"])
//                print("result foodLevel = ",results?.string(forColumn: "petName"))
                if(results?.next())!{
                    //                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!foodLevel = ",Int((results?.int(forColumn: "foodLevel"))!))
                    //                print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!petNAME",results?.string(forColumn: "petName")!)
                    print("pet name = "+(results?.string(forColumn: "petName"))!)
                    mainPet.foodLevel = Int((results?.int(forColumn: "foodLevel"))!)
                    mainPet.happiness = Int((results?.int(forColumn: "happiness"))!)
                    mainPet.fedTimes = Int((results?.int(forColumn: "fedTime"))!)
                    mainPet.playedTimes = Int((results?.int(forColumn: "playTime"))!)
                    mainPet.foodValue = CGFloat(Double(mainPet.foodLevel)/10)
                    mainPet.happyValue = CGFloat(Double(mainPet.happiness)/10)
                    contactDB?.close()
                }else{
//                    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!petNAME",mainPet.petName.rawValue)
                    do {
                        try contactDB?.executeUpdate("insert into pet (petName, foodLevel, happiness, fedTime, playTime) values (?,?,?,?,?)", values: ["\(mainPet.petName.rawValue)","\(mainPet.foodLevel)","\(mainPet.happiness)","\(mainPet.fedTimes)", "\(mainPet.playedTimes)"])
                        contactDB?.close()
                    } catch let error as NSError {
                        print("insert pet",error)
                        contactDB?.close()
                    }
                
                }
            } catch let error as NSError {
                contactDB?.close()
                print("loadDatabase failed \(error)")
            }
        }
    }
    
    func updateDatabase(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let thePath = delegate.PetDbPathInDocument
        let contactDB = FMDatabase(path: thePath)
        print("I am in update!!!!!!!!")
        if !(contactDB?.open())!{
            print("Unable to open db")
            return
        } else {
            do {
                try contactDB?.executeUpdate("update pet set foodLevel = ?, happiness = ?, fedTime = ?, playTime = ? where petName = ?", values: ["\(mainPet.foodLevel)","\(mainPet.happiness)","\(mainPet.fedTimes)","\(mainPet.playedTimes)", "\(mainPet.petName.rawValue)"])
                contactDB?.close()
            } catch let error as NSError {
                contactDB?.close()
                print("updateDatabase failed \(error)")
            }
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

