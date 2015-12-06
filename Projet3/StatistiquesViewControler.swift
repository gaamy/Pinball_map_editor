//
//  StatistiquesViewControler.swift
//  Projet3
//
//  Created by Gabriel Amyot on 2015-12-06.
//  Copyright © 2015 David Gourde. All rights reserved.
//
import UIKit
import Foundation

class StatistiquesViewControler: UIViewController{

    
    ///UI
    @IBOutlet weak var labelNomUtilisateur: UILabel!
    @IBOutlet weak var labelPR: UILabel!
    @IBOutlet weak var labelPG: UILabel!
    @IBOutlet weak var labelPD: UILabel!
    @IBOutlet weak var labelPRJ: UILabel!
    @IBOutlet weak var labelCJ: UILabel!
    @IBOutlet weak var labelLevel: UILabel!
    
    //afficherStatistique
    var nomJoueur = ""
    var PJ = ""
    var PG = ""
    var PD = ""
    var PRJ = ""
    var CJ = ""
    var level = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketSession.sharedInstance.chargerStatistiques()
        
        //attendre 2 sec
        let seconds = 2.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.parserStatistiques(SocketSession.sharedInstance.statistiques)
            self.refreshStatistiques()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
        
        SocketSession.sharedInstance.chargerStatistiques()
        SocketSession.sharedInstance.resetInscription()
        
    }
    
    func parserStatistiques(stats:String){
        nomJoueur = SocketSession.sharedInstance.utilisateur
        let parsedStats = stats.characters.split{$0 == "#"}.map(String.init)
        PJ = parsedStats[0]
        PG = parsedStats[1]
        PD = parsedStats[2]
        PRJ = parsedStats[3]
        CJ = parsedStats[4]
        level = parsedStats[5]
        
    }
    
    func refreshStatistiques(){
        labelNomUtilisateur.text = nomJoueur
        labelPR.text = PJ
        labelPG.text = PG
        labelPD.text = PD
        labelPRJ.text = PRJ
        labelCJ.text = CJ
        labelLevel.text = level
    }
}