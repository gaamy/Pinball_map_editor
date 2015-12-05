//
//  MenuPrincipalViewControler.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-12-05.
//  Copyright © 2015 David Gourde. All rights reserved.
//
import UIKit
import Foundation

class MenuPrincipalViewControler : UIViewController{
    
    var socket : SocketSession!
    
    @IBOutlet weak var boutonClavardage: UIButton!
    
    @IBAction func deconnection(sender: UIButton) {
        if socket != nil{
            socket.disconnect()
            socket = nil
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if socket != nil{
            if socket.isAuthenticate(){
                boutonClavardage.enabled = true
            }else{
                boutonClavardage.enabled = false
            
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}