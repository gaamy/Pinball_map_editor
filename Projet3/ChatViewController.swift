//
//  ChatViewController.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-11-29.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import Foundation
import UIKit

class ChatViewController : UIViewController, NSStreamDelegate, UITextFieldDelegate{

    //UIelements
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var monTexte: UITextField!
    @IBOutlet weak var messages: UITextView!
    @IBOutlet weak var senderButton: UIButton!
    
    //Networking elements
    var socket: WebSocket!
    var serverURL:NSURL!
    var host = ""
    var port = 0
    var userName = ""
    var connected : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monTexte.delegate = self
        
        serverURL = NSURL(fileURLWithPath: "\(self.host): \(self.port)")
        socket = WebSocket(url: serverURL)
        
        //let data = "Hello, ".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
       // joinChat(self.userName)
        
    }
    
    ////---UiFunctions---///
    
    ///updateChatView()
    ///@input: newMessage -> message to be added on the chat view
    ///@output: messages -> updates the message text view
    func updateChatView(message:String){
        
        //we need to get rid of the begining of the message that contains the size of the package
        // Exemple: !!12!salut  -> salut
        
        var unwraped = message
        do {
            unwraped = try message.unwrapServerMessage()
        } catch {
            print(error)
        }
        
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
            envoyer(senderButton)
            monTexte.becomeFirstResponder()
            return false
        }
        return true
    }
    

    
    ////---networking functions---///

    ///Premiere communication avec le serveur
    ///Sert a etablir la connection
    func joinChat(user: String) {
        let response: String = "\(user)"
        let data: NSData = response.dataUsingEncoding(NSUTF8StringEncoding)!
        //socket.emit("joinChat",data)
        //outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    ///Quite le chat
    func quitChat(){
        ///socket.emit("exitChat")
        connected = false
    }
    
    /**
     * Envoy le message au serveur
     * Une entete est ajoutee au message
     * Entete: !!sizeOfTcpMessage!
     */
    @IBAction func envoyer(sender: AnyObject) {
        //TODO: verifier que la connection a ete etablie avant d'envoyer le message
        if monTexte.text! != ""{
            let size : Int = 7 + monTexte.text!.characters.count
            let response: String = "!!\(size)!\(monTexte.text!)\n"
            monTexte.text = ""
            let data: NSData = response.dataUsingEncoding(NSUTF8StringEncoding)!
            //socket.emit("envoyerMessage",UnsafePointer<UInt8>(data.bytes))
            //self.outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        }
    }
    
    
    
    ///socket handlers
    func addHandlers() {
        // Our socket handlers go here
    }
    
}


/**
 * Regex qui detecte et enleve les en-tetes serveur exemple: !!21!
 *
 */
/*
extension String {
    func unwrapServerMessage() throws -> String{
        
        let regex = try! NSRegularExpression(pattern: "!![0-9]+!", options: [.CaseInsensitive])
        let range = NSMakeRange(0, self.characters.count)
        let unwrapedMessage = regex.stringByReplacingMatchesInString(self, options: NSMatchingOptions(rawValue: 0), range: range, withTemplate: "")
        
        return unwrapedMessage
    }
    
}
*/


/*


    /**stream()
     handle the NSStream events.
     It's here where the incomming TCP messages are handled
     */
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch (eventCode){
        case NSStreamEvent.ErrorOccurred:
            NSLog("ErrorOccurred")
            showFirstViewController()
            break
        case NSStreamEvent.EndEncountered:
            NSLog("EndEncountered")
            break
        case NSStreamEvent.None:
            NSLog("None")
            break
        case NSStreamEvent.HasBytesAvailable:
            NSLog("HasBytesAvaible")
            var buffer = [UInt8](count: 4096, repeatedValue: 0)
            if ( aStream == inputStream){
                
                while (inputStream.hasBytesAvailable){
                    let len = inputStream.read(&buffer, maxLength: buffer.count)
                    if(len > 0){
                        let output = NSString(bytes: &buffer, length: buffer.count, encoding: NSUTF8StringEncoding)
                        if (output != ""){
                            print(output!)
                            let stringOutput = output as! String
                            updateChatView(stringOutput)
                            NSLog("server said: %@", output!)
                            
                        }
                    }
                }
            }
            break
        case NSStreamEvent():
            NSLog("allZeros")
            break
        case NSStreamEvent.OpenCompleted:
            NSLog("OpenCompleted")
            if !connected{
                updateChatView("Connected to chat\n")
                connected = true
            }
            break
        case NSStreamEvent.HasSpaceAvailable:
            NSLog("HasSpaceAvailable")
            break
        default:
            NSLog("unknown.")
        }
        
    }


    */
    
    

    



   