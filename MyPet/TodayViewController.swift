//
//  TodayViewController.swift
//  MyPet
//
//  Created by 袁征 on 2017/3/28.
//  Copyright © 2017年 Zheng Yuan. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var healthLabel: UILabel!

    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var healthView: DisplayView!
    @IBOutlet weak var foodView: DisplayView!
    @IBOutlet weak var foodLabel: UILabel!
//    @IBOutlet weak var foodDisplay: DisplayView!
    override func viewDidLoad() {
        super.viewDidLoad()
        petImage.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view from its nib.
        let ud = UserDefaults(suiteName: "group.Lab2.MyLocation")
        let food = ud?.object(forKey: "food") as! Int
        let happy = ud?.object(forKey: "happy") as! Int
//        let test = ud?.object(forKey: "test") as! Int
        let petName = (ud?.string(forKey: "petName"))! as String
        print("petName = "+petName)
        var petColor = UIColor()
        print(food)
        switch petName {
        case "bear":
            petColor = UIColor.darkGray
        case "dog":
            print("in Switch dog")
            petColor = UIColor.brown
        case "duck":
            petColor = UIColor.yellow
        case "forg":
            petColor = UIColor.green
        case "guinea":
            petColor = UIColor.lightGray
        default:
            petColor = UIColor.black
        }
        foodView.color = petColor 
        healthView.color = petColor 
        foodView.animateValue(to: CGFloat(Float(food)/10.0))
        healthView.animateValue(to: CGFloat(Float(happy)/10.0))
        foodLabel.text = "Food: "+String(describing: food)
        healthLabel.text = "Happy: "+String(describing: happy)
        petImage.image = UIImage(named: petName+"Feed.png")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
