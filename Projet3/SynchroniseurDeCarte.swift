//
//  SynchroniseurDeCarte.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-11-29.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import Foundation

class SynchroniseurDeCarte{
    let socket = SocketSession.sharedInstance
    
    func addHandlers() {
        //Attrape tout les evenement qui ne sont pas atrapés par les autres handles
        /*
        self.socket.onAny {
            print("Got event: \($0.event), with items: \($0.items)")
        }
        
        self.socket.on("startGame") {
            [weak self] data, ack in self!.handleStart()
            return
        }
        
        self.socket.on("win") {[weak self] data, ack in
            if let name = data[0] as? String, typeDict = data[1] as? NSDictionary {
                //!.handleWin(name, typeDict: typeDict)
            }
        }
        */
    }

    
    func envoyerCarte(carte : NSData){
        ///envoy un carte sous forme de data
        
        //let data = stringData.dataUsingEncoding(NSUTF8StringEncoding)

        //socket.emit("addMap", carte)
    }
    
    
  
    //Syncronise les donnes entre le serveur et le client
    func actualiserClientLeger(){
    
        //verifie si les carte sur le client leger sont correspondantes avec la liste recu
        //let carteLocales = getLocalSavedFiles()
        //pour chaque fichier different ou introuvable sur le  client leger
            //recevoirCarte()
        
        //pour chaque carte presente sur le client leger mais pas dans la liste
            //envoyerCarte
    }
    
    
    func recevoirCarte(){
        //enrregistrer le fichier recu sous .xml
        //sauvegarderStringXML(stringData: NSString, nomFichier :String
    }
    
    
    
    
    
}