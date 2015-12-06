//
//  MenuPrincipalViewControler.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-12-05.
//  Copyright © 2015 David Gourde. All rights reserved.
//
import UIKit
import Foundation

class MenuPrincipalViewControler : UIViewController{
    
    @IBOutlet weak var boutonClavardage: UIButton!
    
    @IBAction func deconnection(sender: UIButton) {
        
        SocketSession.sharedInstance.disconnect()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        if SocketSession.sharedInstance.isAuthenticate(){
            boutonClavardage.enabled = true
        }else{
            boutonClavardage.enabled = false
            
        }
      
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    
    ///prepare a envoyer la le socket a la prochaine vue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        /*if (segue.identifier == "ShowChat") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            let chatView = segue.destinationViewController as! ChatViewController;
            chatView.socket = self.socket
            //self.socket.connecterChatView(chatView)
        }
        else */if (segue.identifier == "ShowInscription") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            let chatView = segue.destinationViewController as! ChatViewController;
            chatView.socket = self.socket
            //self.socket.connecterChatView(chatView)
        }
    }
*/

}