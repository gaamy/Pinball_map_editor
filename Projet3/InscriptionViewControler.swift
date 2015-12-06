//
//  InscriptionViewControler.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-12-06.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import UIKit
import Foundation

class InscriptionViewControler: UIViewController{
    
    
    @IBOutlet weak var erreurMotDePasseVide: UILabel!
    @IBOutlet weak var erreurNom: UILabel!
    @IBOutlet weak var erreurMotDePasseDifferent: UILabel!
    @IBOutlet weak var nomUtilisateur: UITextField!
    @IBOutlet weak var motDePasse: UITextField!
    @IBOutlet weak var confirmationMotDePasse: UITextField!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        SocketSession.sharedInstance.resetInscription()
        
    }
    
    
    
    @IBAction func inscription(sender: UIButton) {
        self.loadingIndicator.startAnimating()
        erreurNom.hidden = true
        erreurMotDePasseVide.hidden = true
        erreurNom.hidden = true
        
        var nom = ""
        if let monNom = nomUtilisateur.text {
            nom = monNom
        }
        
        var motPasse = ""
        if let passe = motDePasse.text {
            motPasse = passe
        }

        if motPasse != confirmationMotDePasse.text!{
            erreurMotDePasseDifferent.hidden = false
        }else if nom == ""{
            erreurNom.hidden = false
        }else if motPasse == ""{
            erreurMotDePasseVide.hidden = false
        }else{
        
            
            SocketSession.sharedInstance.inscription(nom,nouveauMotDePasse: motPasse)
        

            //attendre 2 sec
            let seconds = 2.0
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.loadingIndicator.stopAnimating()
                if SocketSession.sharedInstance.isInscriptionValide(){
                
                    Popups.SharedInstance.ShowAlert(self,
                        title: "Inscription Effecué",
                        message: "Vous vous êtes inscrit avec succes. Vous pouvez maitenant utiliser votre nom d'utilisateur et mot de passe    pour vous authentifier .",
                        buttons: ["D'accord"]) { (buttonPressed) -> Void in
                            if buttonPressed == "D'accord" {
                                //On fait rien sinon
                                self.performSegueWithIdentifier("InscriptionTermine", sender: self)
                            }
                    }

                }
                else{
                    Popups.SharedInstance.ShowAlert(self,
                        title: "Inscription a échoué",
                        message: "Le nom d'utilisateur choisis existe deja. Réesseyer avec un autre nom d'utilisateur.",
                        buttons: ["D'accord"]) { (buttonPressed) -> Void in
                            if buttonPressed == "D'accord" {
                                //On fait rien sinon
                            }
                    }
            }

            })
        }
        
        
    }
    
    
}