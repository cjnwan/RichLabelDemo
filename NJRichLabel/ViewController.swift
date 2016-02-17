//
//  ViewController.swift
//  NJRichLabel
//
//  Created by 陈剑南 on 16/2/16.
//  Copyright © 2016年 Jimmy Chen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    var label:NJRichLabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
         label = NJRichLabel(frame: CGRectMake(0,100,view.frame.size.width,view.frame.size.height))
       
        label.setText("Hello,Core Text!!!")
        label.appendImage(UIImage.init(named: "1")!)
        label.appendView(UISwitch())
        label.appendView(UIButton())
        label.appendText("cjnwan,haha")
        label.appendView(UISwitch())
        label.appendText("Hello,World")
        view.addSubview(label)

        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

