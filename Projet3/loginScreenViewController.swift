//
//  loginScreenViewController.swift
//  Prototype_Chat
//
//  Created by Gabriel Amyot on 2015-09-13.
//  Copyright (c) 2015 David Gourde. All rights reserved.
//

import UIKit
import Foundation
import Darwin.C


class loginScreenViewController: UIViewController {

    @IBOutlet weak var lblMessage: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    //server information
    @IBOutlet weak var host: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var warningMessage: UILabel!
  
    @IBOutlet weak var usernameReminder1: UILabel!
    
    @IBAction func connectToChat(sender: UIButton) {
        
        // checking for invalid entrys
        if (host.text == nil || host.text!.isEqual("")){
            warningMessage.text = "-J'ai besoin de d'un IP pour me connecter au serveur!-"
            warningMessage.hidden = false
        }
        else if(port.text == nil || Int(port.text!) == nil){
             warningMessage.text = "-On a besoin d'un Port pour qu'une connexion sois effectué!-"
            warningMessage.hidden = false
        }
        else if(userName.text == nil || userName.text == ""){
            warningMessage.text = "-Tu n'a pas de nom!? Utilise ton imagination svp-"
            
            warningMessage.hidden = false
            usernameReminder1.hidden = false
            
        }else if(true){
            
            //check if the connection is possible
            //connect
            //disconect
            
            usernameReminder1.hidden = true
            warningMessage.hidden = true
            showChatView()
        }
    }
    
    

    /*
    * prepareForSegue()
    * this function are responsable for the data transfer 
    * between this view and th hat view!
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "idLoginSegue") {
            let chatViewController : ViewController = segue.destinationViewController as! ViewController
            
            chatViewController.host = self.host.text!
            chatViewController.port = Int(self.port.text!)!
            chatViewController.userName = self.userName.text!
        }
    }
    

    
    //go to the chat view
    func showChatView(){
        self.performSegueWithIdentifier("idLoginSegue", sender: self)
    }
    
  
    
    //when returns from an other view
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue){
        
    }
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            if id == "idFirstSegueUnwind" {
                let unwindSegue = CustonSegueUnwind(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
                    
                })
                return unwindSegue
            }
        }
        
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    }
    

    
}
