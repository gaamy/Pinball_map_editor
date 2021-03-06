//
//  LoginViewControler.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-12-01.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import UIKit
import Foundation


class LoginViewController : UIViewController{

    @IBOutlet weak var host: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var nomUtilisateur: UITextField!
    @IBOutlet weak var motDePasse: UITextField!
    @IBOutlet weak var messageDerreur: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBAction func nouvelUtilisateur(sender: UIButton) {
        if host.text! != "" && port.text! != "" {
            SocketSession.sharedInstance.initialiserConnection(host.text!, port: Int(port.text!)!)
            self.performSegueWithIdentifier("ShowCreationUtilisateur", sender: self)
        }
    }
    @IBAction func authentification(sender: UIButton) {
        // checking for invalid entrys
        if (host.text == nil || host.text!.isEqual("")){
            messageDerreur.text = "-J'ai besoin de d'un IP pour me connecter au serveur!-"
            messageDerreur.hidden = false
        }
        else if(port.text == nil || Int(port.text!) == nil){
            messageDerreur.text = "-On a besoin d'un Port pour qu'une connexion sois effectué!-"
            messageDerreur.hidden = false
        }
        else if(nomUtilisateur.text == nil || nomUtilisateur.text == ""){
            messageDerreur.text = "-Tu n'a pas de nom!? Utilise ton imagination svp-"
            
            messageDerreur.hidden = false
            //usernameReminder1.hidden = false
            
        }else if(true){
           // usernameReminder1.hidden = true
            messageDerreur.hidden = true
            
            //animation de chagement
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            loginButton.enabled = false
            
            let portString = port.text!
            let hostString = host.text!

            
            SocketSession.sharedInstance.initialiserConnection(hostString, port: Int(portString)!)
            
            SocketSession.sharedInstance.debuterSession(nomUtilisateur.text!, motDePasse: motDePasse.text!)
            
            if SocketSession.sharedInstance.isAuthenticate(){
                activityIndicator.stopAnimating()
                loginButton.enabled = true
                performShowMenuSegue()
                
            }else{
                //attendre Reponse 3.0 sec
                let seconds = 3.0
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                    self.loginButton.enabled = true
                    if SocketSession.sharedInstance.isAuthenticate(){
                        self.performShowMenuSegue()
                    }
                    else{
                        
                        var erreur = " Erreur de connection"
                        if SocketSession.sharedInstance.erreur{
                            erreur = SocketSession.sharedInstance.typeErreur
                        }
                        
                        Popups.SharedInstance.ShowAlert(self,
                            title: "Erreur d'authentification",
                            message: erreur,
                            buttons: ["D'accord"]) { (buttonPressed) -> Void in
                                if buttonPressed == "D'accord" {
                                    self.motDePasse.text = ""
                                
                                }
                        }

                        
                    }
                    
                    
                })
            
            }
            
        }
        
        
    
    }


    
    //go to the chat view
    func performShowMenuSegue(){
        self.performSegueWithIdentifier("ShowMenu", sender: self)
    }
    
    /*
    ///prepare a envoyer la le socket a la prochaine vue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "ShowMenu") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            let menuPrincipal = segue.destinationViewController as! MenuPrincipalViewControler;
            menuPrincipal.socket = self.socket
        }
    }
    */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //if socket != nil{
            //socket.disconnect()
       // }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

