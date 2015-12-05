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
        let seconds = 0.2
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            //socket.
           
            self.socket.sendEvent("authentification", withData: "\(nomUtilisateur)#\(motDePasse)")
            
            
        })
        
        
     //  self.socket.sendEvent("authentification", withData: "\(nomUtilisateur)#\(motDePasse)")
        
        
        
    }
    

    // message delegate
    func socketIO(socket: SocketIO, didReceiveMessage packet: SocketIOPacket) {
        NSLog("didReceiveMessage >>> data: %@", packet.data)
        print("---------this is a message ! : \(packet.data)")
        
        //packet.data
    }
    
    // event delegate
    
    func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {
        NSLog("didReceiveEvent >>> data: %@", packet.data)
        print("----------------this is a event ! : \(packet.data)")
        
        
        
        
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
        
        socket.on("connect") {data, ack in
            print("socket connected")
            print(data)
            print(ack)
            self.connected = true
            self.socket.sendEvent("authentification", withData: "gaamy#test")
            
        }
        
        self.socket.onAny {
            print("Got event: \($0.event), with items: \($0.items!)")
        }
        
    }
    */
    
    
    func connectionAccepte(message : String){
        self.connected = true
        print(message)
        
    }
    
    func rejoindreClavardage(user: String) {
        //let response: String = "\(user)"
        //let data: NSData = response.dataUsingEncoding(NSUTF8StringEncoding)!
        //socket.emit("joinChat",data)
        //outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    ///Quite le chat
    func disconnect(){
        self.socket.sendEvent("exit", withData: "\(self.utilisateur)")
        connected = false
    }
    
    /**
     * Envoy le message au serveur
     * Une entete est ajoutee au message
     * Entete: !!sizeOfTcpMessage!
     */
    @IBAction func envoyerMessageChat(sender: AnyObject) {
        //TODO: verifier que la connection a ete etablie avant d'envoyer le message
        //if monTexte.text! != ""{
         //   let size : Int = 7 + monTexte.text!.characters.count
          //  let response: String = "!!\(size)!\(monTexte.text!)\n"
           // monTexte.text = ""
            //let data: NSData = response.dataUsingEncoding(NSUTF8StringEncoding)!
            //socket.emit("envoyerMessage",UnsafePointer<UInt8>(data.bytes))
            //self.outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        //}
    }
    
    
    func creeNouvelUtilisateur(){
    
    }
    
    
    func isAuthenticate() -> Bool  {
        return self.authenticate
    }
}
