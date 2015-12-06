//
//  PopupsText.swift
//  FLLike
//
//  Created by Tom Swindell on 25/05/2015.
//  Copyright (c) 2015 Tom Swindell. All rights reserved.
//

import Foundation
import UIKit

class PopupsText {
    class var SharedInstance: PopupsText {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: PopupsText? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = PopupsText()
        }
        return Static.instance!
    }
    
    var alertComletion : ((String) -> Void)!
    var alertButtons : [String]!
    var tField: UITextField!
    
    func getTextField() -> String
    {
        return tField.text!
    }
    
    func configurationTextField(textField: UITextField!)
    {
        textField.placeholder = "Zone"
        tField = textField
    }
    
    func ShowAlert(sender: UIViewController, title: String, message: String, buttons : [String], texteInitial: String, completion: ((buttonPressed: String) -> Void)?) {
        
        let aboveIOS7 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
        if(aboveIOS7) {
            
            let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            alertView.addTextFieldWithConfigurationHandler(configurationTextField)
            
            if texteInitial != "nouvelle_carte" {
                tField.text = texteInitial
            }
            
            for b in buttons {
                
                alertView.addAction(UIAlertAction(title: b, style: UIAlertActionStyle.Default, handler: {
                    (action : UIAlertAction) -> Void in
                    completion!(buttonPressed: action.title!)
                }))
                
                
            }
            sender.presentViewController(alertView, animated: true, completion: nil)
            
        } else {
            
            self.alertComletion = completion
            self.alertButtons = buttons
            let alertView  = UIAlertView()
            alertView.delegate = self
            alertView.title = title
            alertView.message = message
            
            for b in buttons {
                
                alertView.addButtonWithTitle(b)
                
            }
            
            alertView.show()
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(self.alertComletion != nil) {
            self.alertComletion!(self.alertButtons[buttonIndex])
        }
    }
    
    
    
    func ShowPopup(title : String, message : String) {
        let alert: UIAlertView = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButtonWithTitle("Ok")
        
        alert.show()
    }
}