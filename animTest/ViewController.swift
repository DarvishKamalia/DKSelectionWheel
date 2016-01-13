//
//  ViewController.swift
//  animTest
//
//  Created by Darvish Kamalia on 12/31/15.
//  Copyright © 2015 Darvish Kamalia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let wheel = DKSelectionWheelView(frame: self.view.frame)
        self.view.addSubview(wheel)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

