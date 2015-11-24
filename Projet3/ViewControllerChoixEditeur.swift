//
//  ViewController.swift
//  NSXMLparser_tutorial
//
//  Created by Gabriel Amyot on 2015-11-09.
//  Copyright © 2015 tutorials. All rights reserved.
//

import UIKit

class ViewControllerChoixEditeur: UIViewController, UITableViewDelegate, UITableViewDataSource {
    ///xml
    var parseur = ParseurXML()
    var fichierSelectionne: NSURL!
    
    @IBOutlet var tableView: UITableView!
    var items = Array<String>()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        ///Remplis la liste d<items avec le nom des fichiers xml qui on ete parse
        for fichiers in parseur.fichiersSauvegardeURLs{
            items.append(fichiers.lastPathComponent!)
        }
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    
    @IBAction func editerCarteChoisis(sender: UIButton) {
        ///parse le fichier selectionne
        if fichierSelectionne != nil{
            parseur.parseXMLFile(fichierSelectionne.lastPathComponent!)
        }
        ///TODO:: corriger le bug: le mode editeur ouvre meme si aucune carte n'est seletionne
    }
    
    
    ///table view functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    ///Declanche quand une ligne de la table view est selectionne
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        ///
        let ligneSelectionne = indexPath.row
        ///vas chercher le nom du fichier dans la liste filesURL a la position "ligneSelectionne" cela fonctionne car le table view presente les items dans l'ordre qui les a trouve dans "parser.filesURL"
        fichierSelectionne = parseur.fichiersSauvegardeURLs[ligneSelectionne]
    }
    
    
    ///prepare a envoyer la carte au mode editeur
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "editSegue") {
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            let gameControler = segue.destinationViewController as! GameViewController;
            gameControler.carte = parseur.carteActuelle
        }
    }
    
 
    
}
    






