//
//  SocketSession.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-11-30.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import Foundation


class SocketSession : NSObject, SocketIODelegate{
    
    
    var socket : SocketIO!
    var utilisateur = ""
    var motDePasse = ""
    var connected = false
    var authenticate = false
    
    
    init(host: String, port:Int){
        super.init()
        socket = SocketIO(delegate:  self)
        //socket.connectToHost("localhost", onPort: 8000)
        socket.connectToHost("\(host)", onPort: port)
        
    }
    
    ///Connection au serveur
    func debuterSession(nomUtilisateur:String, motDePasse:String) {
        self.utilisateur = nomUtilisateur
        self.motDePasse = motDePasse
        
        
        //attendre 0.2 secondes avant de lancer l'authentification
        let seconds = 1.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            if self.connected{
                self.socket.sendEvent("authentification", withData: "\(nomUtilisateur)#\(motDePasse)")
            }
        })
        
        
    }
    

    // message delegate
    func socketIO(socket: SocketIO, didReceiveMessage packet: SocketIOPacket) {
        //NSLog("didReceiveMessage >>> data: %@", packet.data)
        print("---------this is a message ! : \(packet.data)")
        
       
    }
    //handle la connection
    func socketIODidConnect(socket: SocketIO) {
        connected = true
        print("socketIODidConnect!!!!!!!!!!!!!")
        
    }
    
    
    // event delegate
    func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {
       // NSLog("didReceiveEvent >>> data: %@", packet.data)
        //print("----------------this is a event ! : \(packet.data)")
        
        let dict = convertStringToDictionary(packet.data)

        let event = dict!["name"]! as! String
        let args  = dict!["args"]! as! [String]

        
        switch(event){
            case "connect":
                connected = true
                print("connected!!!!!!!!!!!!!!")
            /*
            case "userConnected":
                if args[0] == "\(utilisateur)"{
                    authenticate = true
                    print("\(args[0]) is authenticated!*************")
                }
            */
            case "reponse connection":
                if args[0] == "true#\(utilisateur)"{
                    authenticate = true
                    print("authenticate!!!!!!!!!!!!!!")
                }
            
            case "userDisconnected":
                authenticate = false
                print("\(args[0]) disconnected!!!!!!!!!!!!!!")
            
            case  "error":
                print("Erreur avec socket.io: arguments: \(args)")
            
            case "message":
                print("Message: \(args)")
            
            default:
                print("--Evenement inconu: \(event)")
                print("--Arguments: \(args)")
            
        
        }
        
        
    }
    
    /*

    func ajouterHandlers(){
        self.socket.on("reponse connection") {[weak self] data, ack in
            self?.connectionAccepte(data[0] as! String)
            
            return
        }
        
        self.socket.on("error") {data in
            print("socket ERROR")
            print(data)
        }
  
        
        self.socket.onAny {
            print("Got event: \($0.event), with items: \($0.items!)")
        }
        
    }
    */
    
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
    
 
    func isAuthenticate() -> Bool  {
        return self.authenticate
    }
    
    func connectionAccepte(message : String){
        self.connected = true
        
    }
}
