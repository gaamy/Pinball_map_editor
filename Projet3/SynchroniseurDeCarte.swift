//
//  SynchroniseurDeCarte.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-11-29.
//  Copyright © 2015 David Gourde. All rights reserved.
//


/*nottes

liste des fichiers local

aller chercher la date et lheure dans le xml

pour chaque fichier
    emit("upDateMap","nomFichier#date#heure")
    si le serveur ne toruves pas la map  ou pas a jour on.("uploadMap", nomMap)
        emit("downloadMap","nomMap#XMLString")
    si la map existe mais n'est pas a jour sur le local, .on("editMap","nomMap#XMLString")
        remplacer le fichier local
*/

import Foundation

class SynchroniseurDeCarte{
    let socket = SocketSession.sharedInstance
    
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