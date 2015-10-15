//
//  CustonSegue.swift
//  Prototype_Chat
//
//  Created by Gabriel Amyot on 2015-09-13.
//  Copyright (c) 2015 David Gourde. All rights reserved.
//

import UIKit

class CustonSegue: UIStoryboardSegue {
    
    override func perform() {
        //Assign the source and destination views to local variables
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!
        
        //get the creen width and height
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        
        //specify the initial position of the destination view.
        secondVCView.frame = CGRectMake(0.0, screenHeight, screenWidth, screenHeight)
        
        //Acces the app's key window and insert the destination view above the current (source one)
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        
        
        //Animae the transition
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            firstVCView.frame = CGRectOffset(firstVCView.frame, 0.0, -screenHeight)
            secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, -screenHeight)
            }) {(Finished) -> Void in
                
                self.sourceViewController.presentViewController(
                    self.destinationViewController ,
                    animated: false,
                    completion: nil
                )
        }
       
    }
   
}
