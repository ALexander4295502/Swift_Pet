//
//  Pets.swift
//  Lab2
//
//  Created by Alexander on 2017/1/31.
//  Copyright © 2017年 Zheng Yuan. All rights reserved.
//
import UIKit
import Foundation
import SwiftGif
import AudioToolbox
import AVFoundation

class pet {
    enum petVariaty:String{
        case bear
        case dog
        case guinea
        case frog
        case duck
    }
    
    var petName:petVariaty
    var happiness:Int
    var foodLevel:Int
    var petColor:UIColor
    var playedTimes:Int
    var fedTimes:Int
    var happyValue:CGFloat
    var foodValue:CGFloat
    
    var normalImage:UIImage
    var sadImage:UIImage
    var feedImage:UIImage
    var playImage:UIImage
    var happyImage:UIImage
    var foodIcon:UIImage
    var playIcon:UIImage
    var petPresentImage:UIImage
    
    var player = AVAudioPlayer()
    var playLongSound:SystemSoundID = 0
    //behavior
    
    func petImageUpdate() -> (UIImage){
        if(happiness < 2 || foodLevel < 2){
            if self.player.isPlaying {
                player.stop()
            }
            petPresentImage = sadImage
        }else if(happiness < 3 || foodLevel < 3){
            if self.player.isPlaying {
                player.stop()
            }
            petPresentImage = normalImage
        }else{
            if !self.player.isPlaying {
                player.play()
            }
            petPresentImage = happyImage
        }
        return petPresentImage
    }
    
    func playIconUpdate() -> (CGFloat){
        if(happiness < 2){
            return CGFloat(1.0)
        }else{
            return CGFloat(0.0)
        }
    }
    
    func foodIconUpdate() -> (CGFloat){
        if(foodLevel < 2){
            return CGFloat(1.0)
        }else{
            return CGFloat(0.0)
        }
    }
    
    func play(Cold:Bool) -> (Bool){
        if(foodLevel > 0){
            happiness += 1
            if(happiness>=10){
                happiness = 10
            }
            if Cold == true{
                foodLevel -= 2
            } else {
                foodLevel -= 1
            }
            
            if(foodLevel <= 0){
                foodLevel = 0
            }
            playedTimes += 1
            foodValue = CGFloat(Double(foodLevel)/10)
            happyValue = CGFloat(Double(happiness)/10)
            return true
        }
        return false
    }
    
    func feed() -> (Bool){
        
        if(foodLevel == 10){
            return false
        }else{
            foodLevel += 1
            happiness -= 1
            if(happiness <= 0){
                happiness = 0
            }
            fedTimes += 1
            foodValue = CGFloat(Double(foodLevel)/10)
            happyValue = CGFloat(Double(happiness)/10)
            return true
        }
    }
    
    init(name:petVariaty, color:UIColor){
        self.petName = name
        if let unwrappedImage = UIImage.gif(name: petName.rawValue+"Normal"){
            self.normalImage = unwrappedImage
        }else{
            print("Error: "+petName.rawValue+"Normal"+" not found!")
            exit(1)
        }
        
        if let unwrappedImage = UIImage.gif(name: petName.rawValue+"Happy"){
            self.happyImage = unwrappedImage
        }else{
            print("Error: "+petName.rawValue+"Happy"+" not found!")
            exit(1)
        }
        
        if let unwrappedImage = UIImage.gif(name: petName.rawValue+"Sad"){
            self.sadImage = unwrappedImage
            self.petPresentImage = self.sadImage
        }else{
            print("Error: "+petName.rawValue+"Sad"+" not found!")
            exit(1)
        }
        
        if let unwrappedImage = UIImage.gif(name: petName.rawValue+"Play"){
            self.playImage = unwrappedImage
        }else{
            print("Error: "+petName.rawValue+"Play"+" not found!")
            exit(1)
        }
        
        if let unwrappedImage = UIImage.gif(name: petName.rawValue+"Feed"){
            self.feedImage = unwrappedImage
        }else{
            print("Error: "+petName.rawValue+"Feed"+" not found!")
            exit(1)
        }
        
        if let unwrappedImage = UIImage(named: "game2.png"){
            self.playIcon = unwrappedImage
        }else{
            print("Error: "+"game2.png"+" not found!")
            exit(1)
        }
        
        if let unwrappedImage = UIImage(named: "pizza.png"){
            self.foodIcon = unwrappedImage
        }else{
            print("Error: "+"pizza.png"+" not found!")
            exit(1)
        }
        
        let url = Bundle.main.url(forResource: "playLong", withExtension: "wav")!
        
        do
        {
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil)
        }
        catch let error as NSError { print(error.description) }
        
        player.numberOfLoops = 1
        player.prepareToPlay()
        
        self.happiness = 0
        self.foodLevel = 0
        self.happyValue = 0
        self.foodValue = 0
        self.playedTimes = 0
        self.fedTimes = 0
        self.petColor = color
    }
    
    func createSound(inputName: String, inputType: String) -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), inputName as CFString!, inputType as CFString!, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        return soundID
    }
    
}
