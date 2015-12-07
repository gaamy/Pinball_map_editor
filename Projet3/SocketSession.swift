//
//  SocketSession.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-11-30.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import Foundation


class SocketSession : NSObject, SocketIODelegate{

    static let sharedInstance = SocketSession()
    
    var socket : SocketIO!
    var utilisateur = ""
    //var motDePasse = ""
    var connected = false
    var authenticate = false
    var erreur = false
    var typeErreur = ""
    var inscriptionValide = false
    var statistiques = ""
    
    //views
    var chat: ChatViewController!
    
    private override init(){
        super.init()
    }


    
    func initialiserConnection(host: String, port:Int){
        
        socket = SocketIO(delegate:  self)
        //socket.connectToHost("localhost", onPort: 8000)
        socket.connectToHost("\(host)", onPort: port)
    }
    
    
    ///Connection au serveur
    func debuterSession(nomUtilisateur:String, motDePasse:String) {
        self.utilisateur = nomUtilisateur
      //  self.motDePasse = motDePasse
        
        //attendre 1.0 secondes avant de lancer l'authentification
        let seconds = 1.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            if self.connected{
                self.socket.sendEvent("authentification", withData: "\(nomUtilisateur)#\(motDePasse)")
            }
        })
    }
    
    ///socketIO
    ///message delegate
    func socketIO(socket: SocketIO, didReceiveMessage packet: SocketIOPacket) {
        //NSLog("didReceiveMessage >>> data: %@", packet.data)
        print("---------this is a message ! : \(packet.data)")
       
    }
    
    ///socketIO
    ///handle la connection delegate
    func socketIODidConnect(socket: SocketIO) {
        connected = true
        print("socketIODidConnect!!!!!!!!!!!!!")
        
    }
    /*
    ///SocketIO
    //Handle disconection
    override func socketIODidDisconnect(socket: SocketIO, disconnectedWithError error: NSErrorPointer) {
            print("dicon
                ected")
    }
    */
    
    
    ///socketIO
    ///event delegate
    func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {
        let dict = convertStringToDictionary(packet.data)
        let event = dict!["name"]! as! String
        
        
        
        
        
        switch(event){
            case "reponse connection":
                let args  = dict!["args"]! as! [String]
                let reponseComplete = args[0]

                let reponse = reponseComplete.characters.split{$0 == "#"}.map(String.init)
                
                switch (reponse[0]){
                    case "true":
                        SocketSession.sharedInstance.authenticate = true
                        erreur = false
                        print("authenticate!!!!!!!!!!!!!!")
                    case "false":
                        erreur = true
                        SocketSession.sharedInstance.authenticate  = false
                        typeErreur = reponse[1]
                    
                    default:
                        let args  = dict!["args"]! as! [String]
                        print("reponse connection not handle :\(args[0])")
                }
            case "userDisconnected":
                authenticate = false
                print(" disconnected!!!!!!!!!!!!!!")
            
            
            case  "error":
                let args  = dict!["args"]! as! [String]
                print("Erreur avec socket.io: arguments: \(args)")
           
            //gestidu chat
            case "txt":
                let args  = dict!["args"]! as! [String]
                print("General chat message: \(args[0])")
            chat.updateChatView(args[0])
            
            //case "roomChatReceive":
                //print("roomChatReceive message recu")
            
            case "message":
                let args  = dict!["args"]! as! [String]
                print("Message: \(args)")
            
            case "User Disconected": break
            
            
            case "reponse register":
                let args  = dict!["args"]! as! [String]
                if args[0] == "true#Le compte a été ajouté avec succès"{
                    self.inscriptionValide = true
                }else if args[0] == "false#Nom d'utilisateur deja present, veuillez voisir un autre nom d'utilisateur"{
                    self.inscriptionValide = false
                }
            
            case "afficherStatistique":
                let args  = dict!["args"]! as! [String]
                statistiques = args[0]
        
            case "uploadMap":
                let args  = dict!["args"]! as! [String]
                SynchroniseurDeCarte.sharedInstace.actualiserCarteServeur(args[0])
        
            case "editMap":
                let args  = dict!["args"]! as! [String]
                let reponse = args[0].characters.split{$0 == "#"}.map(String.init)
                
                SynchroniseurDeCarte.sharedInstace.actualiserCarteLocale(reponse[0],carteXML: reponse[1])
            
            default:
                //if let args  = dict!["args"]! as? [String]{
                 //   print("--Evenement inconu: \(event)")
                   //  print("--Arguments: \(args)")
               // }
              //  else{
                    print("--Evenement FUCKENT: \(event)")
             //   }
               // print("--Evenement inconu: \(event)")
               // print("--Arguments: \(args)")
            
        
        }
        
        
    }
    
    
    
    //SocketIO
    //envoyerMessage au chat
    func envoyerMessageChat(message:String){
        self.socket.sendEvent("general message", withData: message)
        
    
    }
    
    
    ///Cette méthode associe le view controller du chat a la variable chat du socket
    ///Le but de cette methode est davoir acces au ChatViewController et d'actualiser la valeur de messages quand un npouveau message est recu
    ///Cette approche nest pas optimal ( le modele qui modifie la vue) (this is disgusting holy shit!)
    func connecterChatView(chat:ChatViewController){
        self.chat = chat
    
    }
    
    func deconnecterChatView(){
        self.chat = nil
    }
    
    
    //Convertis un fichier jSon en dictionaire
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Erreur: Conversion jSon -> string ")
            }
        }
        return nil
    }
    
    ///Quite le chat
    func disconnect(){
        self.socket.sendEvent("exit", withData: "\(self.utilisateur)")
        connected = false
        authenticate = false
    }
    
    ///nouvelle inscription
    func inscription(nouvelUtilisateur: String, nouveauMotDePasse: String){
        self.socket.sendEvent("register", withData: "\(nouvelUtilisateur)#\(nouveauMotDePasse)")
    }
    
    ///charger statistiques du joueur en cours
    func chargerStatistiques(){
        self.socket.sendEvent("afficherStatistique",withData: self.utilisateur)
    }
    
    //envoy une carte au serveur
    func envoyerCarte(nomCarte:String, carteXML:String){
        self.socket.sendEvent("downloadMap", withData: "\(nomCarte)# \(carteXML)")
    }
    
    ///Syncro
    func upDateServeur(nomCarte: String, date :String, heure: String){
        
        let data = "\(nomCarte)#\(date)#\(heure)"
        self.socket.sendEvent("upDateMap", withData:data )

    }
    
    
    ///reset les configurations d'inscription
    func resetInscription(){
        self.inscriptionValide = false
    }
    
    func isInscriptionValide() -> Bool{
        return self.inscriptionValide
    }
 
    func isAuthenticate() -> Bool  {
        return self.authenticate
    }
    
    func connectionAccepte(message : String){
        self.connected = true
        
    }
}
