//
//  ViewController.swift
//  Prototype_Chat
//
//  Created by David Gourde on 2015-09-03.
//  Copyright (c) 2015 David Gourde. All rights reserved.
//

import UIKit

//this view controller represents the chat main view controller
class ViewController: UIViewController, NSStreamDelegate, UITextFieldDelegate  {
    
    //UI elements
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var monTexte: UITextField!
    @IBOutlet weak var messages: UITextView!
    @IBOutlet weak var senderButton: UIButton!
    
    //imported elements
    var host = ""
    var port = 0
    var userName = ""
    


    /*
        this is the first function to be called when the view loads
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        monTexte.delegate = self
        initNetworkCommunication(self.host as CFString, connectionPort:UInt32(self.port))
        
        joinChat(self.userName)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //-------Networking------//

    //Client Socket stream
    var inputStream: NSInputStream!
    var outputStream: NSOutputStream!
    var connected : Bool = false
    
    func initNetworkCommunication(connectionHost: CFString, connectionPort: UInt32)  {
        var readstream : Unmanaged<CFReadStream>?
        var writestream : Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, connectionHost, connectionPort, &readstream, &writestream)
        inputStream = readstream!.takeRetainedValue()
        outputStream = writestream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        inputStream.open()
        outputStream.open()
    }
    
    /**
    @input: userName
    @output:
    */
    func joinChat(user: String) {
        let response: String = "\(user)"
        let data: NSData = response.dataUsingEncoding(NSUTF8StringEncoding)!
        outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    func quitChat(){
        
        inputStream.close()
        outputStream.close()
        connected = false
    }
    
    /**
    * Envoy le message au serveur
    * Une entete est ajoutee au message
    * Entete: !!sizeOfTcpMessage!
    */
    @IBAction func envoyer(sender: AnyObject) {
        //send the message to the server
        
        //TODO: verifier que la connection a ete etablie avant d'envoyer le message
        if monTexte.text! != ""{
            let size : Int = 7 + monTexte.text!.characters.count
            let response: String = "!!\(size)!\(monTexte.text!)\n"
            monTexte.text = ""
            let data: NSData = response.dataUsingEncoding(NSUTF8StringEncoding)!
            self.outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        }
    }
    
  
    /*
    * detecte la touche "entre" et envoie le message
    * le focus reviens automatiquement
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.monTexte {
            textField.resignFirstResponder()
            envoyer(senderButton)
            monTexte.becomeFirstResponder()
            return false
        }
        return true
    }
    

    
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
    /*updateChatView()
    
    @input: newMessage -> message to be added on the chat view
    @output: messages -> updates the message text view
    */
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

    
    
    
    
    
    //---------Segue manengement(Transitions)-------------
    
    /*
        IBAction from
    */
    @IBAction func backToLoginView(sender: UIButton) {
        showFirstViewController()
    }
    
    /*
    * show the login screen
    */
    func showFirstViewController() {
        inputStream.close()
        outputStream.close()
        self.performSegueWithIdentifier("idFirstSegueUnwind", sender: self)
    }
    
    }


/**
* Regex qui detecte et enleve les en-tetes serveur exemple: !!21!
*
*/
extension String {
    func unwrapServerMessage() throws -> String{
        
        let regex = try! NSRegularExpression(pattern: "!![0-9]+!", options: [.CaseInsensitive])
        let range = NSMakeRange(0, self.characters.count)
        let unwrapedMessage = regex.stringByReplacingMatchesInString(self, options: NSMatchingOptions(rawValue: 0), range: range, withTemplate: "")
    
        return unwrapedMessage
    }
    
}

   