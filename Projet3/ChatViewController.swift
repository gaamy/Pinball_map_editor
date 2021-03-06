//
//  ChatViewController.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-11-29.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import Foundation
import UIKit

class ChatViewController : UIViewController, UITextFieldDelegate{

    //UIelements
    @IBOutlet weak var boutonEnvoyerMessage: UIButton!
    @IBOutlet weak var messages: UITextView!
    @IBOutlet weak var monTexte: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monTexte.delegate = self
        ///Aberation:TODO:correct that after project deadline
        SocketSession.sharedInstance.connecterChatView(self)
        
        
    }
    

    ////---UiFunctions---///
    
    ///updateChatView()
    ///@input: newMessage -> message to be added on the chat view
    ///@output: messages -> updates the message text view
    func updateChatView(message:String){
        
        let unwraped = message

        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        formatter.stringFromDate(date)
        messages.text! = formatter.stringFromDate(date) + ":  " + unwraped + "\n" + messages.text!
        
    }
    
    
    /// detecte la touche "entre" et envoie le message le focus reviens automatiquement
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.monTexte {
            textField.resignFirstResponder()
            envoyer(boutonEnvoyerMessage)
            monTexte.becomeFirstResponder()
            return false
        }
        return true
    }
    
  
    /**
     * Envoy le message au serveur
     * Une entete est ajoutee au message
     * Entete: !!sizeOfTcpMessage!
     */
    @IBAction func envoyer(sender: AnyObject) {
        if monTexte.text! != ""{
            let response: String = "\(monTexte.text!)\n"
            monTexte.text = ""
            
          
            SocketSession.sharedInstance.envoyerMessageChat(response)
           
            
        }
    }
    /*
    
    ///prepare a envoyer la le socket a la prochaine vue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "ShowMenu") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            let menuView = segue.destinationViewController as! MenuPrincipalViewControler;
            menuView.socket = self.socket
            
        }
    }

    */

    ///détache ce chat view du socket 
    @IBAction func quiterChat(){
        //cecy crash a la deusiemme fois quon ferme le chat
        //socket.deconnecterChatView()
    }
  
    
    ////---networking functions---///
    ///Premiere communication avec le serveur
    ///Sert a etablir la connection
    func joinChat(user: String) {
        //let response: String = "\(user)"
        
        
    
        
    }

    
    
}


    



   