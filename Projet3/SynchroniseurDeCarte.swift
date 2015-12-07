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
    //Singleton
    static let sharedInstace = SynchroniseurDeCarte()
    
    
    let socket = SocketSession.sharedInstance
    let parseur = ParseurXML()
    
    
    private init(){
        
    }

    
    func actualiserClientLeger(){
    
        //verifie si les carte sur le client leger sont correspondantes avec la liste recu
        //let carteLocales = getLocalSavedFiles()
        //pour chaque fichier different ou introuvable sur le  client leger
        //recevoirCarte()
        
        //pour chaque carte presente sur le client leger mais pas dans la liste
        //envoyerCarte

    
    }
    
  
    ///Syncronise les donnes sur le serveur
    /*
    pour chaque fichier
        emit("upDateMap","nomFichier#date#heure")
            si le serveur ne toruves pas la map  ou pas a jour on.("uploadMap", nomMap)
                emit("downloadMap","nomMap#XMLString")
            si la map existe mais n'est pas a jour sur le local, .on("editMap","nomMap#XMLString")
                remplacer le fichier local
    */
    func actualiserServeur(){
        let cartesLocales = parseur.recupererFichiers()
        //let cartesLocales = parseur.getLocalSavedFiles()
        for carte in cartesLocales{
            parseur.parseXMLFile(carte)
            let carte = parseur.carteActuelle
            SocketSession.sharedInstance.upDateServeur(carte.nomFichier, date: carte.date, heure: carte.time)
        }
    }
    
    
    ///func recevoirCarte(nomCarte: String){
        //enrregistrer le fichier recu sous .xml
        //sauvegarderStringXML(stringData: NSString, nomFichier :String
    //}
    
    
    func actualiserCarteLocale(nomCarte : String, carteXML : String){
        parseur.sauvegarderStringXML(carteXML, nomFichier: nomCarte)
    }
    
    func actualiserCarteServeur(nomCarte: String){
        parseur.parseXMLFile(nomCarte)
        let carte = parseur.carteActuelle
        SocketSession.sharedInstance.envoyerCarte(nomCarte,carteXML: carte.toXmlString() as String)
    }
    
    
    
    
    
}