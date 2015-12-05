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
    
    @IBAction func deconnection(sender: UIButton) {
        if socket != nil{
            socket.disconnect()
            socket = nil
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
           }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}