//
//  GameScene.swift
//  Projet3
//
//  Created by David Gourde on 2015-09-15.
//  Copyright (c) 2015 David Gourde. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    //Variables globale à la classe
    var nodesSelected = [SKSpriteNode]()
    var savedSelected = [SKSpriteNode]()
    var selection = false
    var sprite = SKSpriteNode()
    var construireMur = false
    let chemin = CGPathCreateMutable()
    var murTemp = SKNode()
    //Les variables de son
    var sonCorbeille: SystemSoundID = 0
    var sonObjSurTable: SystemSoundID = 0
    var sonSelectionOutil: SystemSoundID = 0
    var sonSelection: SystemSoundID = 0
    
    //Les listes de noms
    let listeDesBoutons = [
        "boutonaccelerateur",
        "boutonbutoirCirc",
        "boutonbutoirTriDroit",
        "boutonbutoirTriGauche",
        "boutoncible",
        "boutondestructeur",
        "boutongenerateur",
        "boutonpaletteDroite1",
        "boutonpaletteDroite2",
        "boutonpaletteGauche1",
        "boutonpaletteGauche2",
        "boutonportail",
        "boutonressort",
        "boutontrou"]
    let listeDesObjets = [
        "accelerateur",
        "butoirCirc",
        "butoirTriDroit",
        "butoirTriGauche",
        "cible",
        "destructeur",
        "generateur",
        "paletteDroite1",
        "paletteDroite2",
        "paletteGauche1",
        "paletteGauche2",
        "portail",
        "ressort",
        "trou",
        "mur"]
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        sprite.name = "Spaceship"
        initLesSons()
        updateVisibiliteCorbeille()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        //test
        let debutMur = touches.first
        let position1 = debutMur!.locationInNode(self)
        CGPathMoveToPoint(chemin, nil, position1.x, position1.y)
        //finTest
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)

            if let name = touchedNode.name
            {
                if name == "boutonmur" {
                    construireMur = true
                    // jouer un son
                    AudioServicesPlaySystemSound(sonSelectionOutil);
                }
                
                if !listeDesObjets.contains(name)
                {
                    if selection
                    {
                        if name == "save_select"
                        {
                            savedSelected = nodesSelected
                        }
                        
                        if name == "same_select" && nodesSelected.count == 1
                        {
                            for enfant in self.children
                            {
                                if enfant.name == nodesSelected[0].name
                                {
                                    if let monEnfant = enfant as? SKSpriteNode
                                    {
                                        nodesSelected.append(monEnfant)
                                        monEnfant.alpha = 0.5
                                    }
                                }
                            }
                        }else
                        {
                            selection = false
                            updateVisibiliteCorbeille()
                            if name == "boutonDelete"
                            {
                                for node in nodesSelected
                                {
                                    savedSelected = savedSelected.filter {$0 != node}
                                    node.removeFromParent()
                                }
                                
                                // jouer un son
                                AudioServicesPlaySystemSound(sonCorbeille);
                            }
                            for node in nodesSelected
                            {
                                node.alpha = 1
                            }
                            nodesSelected.removeAll()
                        }
                    }else
                    {
                        if listeDesBoutons.contains(name){
                            construireMur = false
                            let nomObjet = name.substringFromIndex(name.startIndex.advancedBy(6))
                            sprite = SKSpriteNode(imageNamed: nomObjet)
                            sprite.name = nomObjet
                            // jouer un son
                            AudioServicesPlaySystemSound(sonSelectionOutil);
                        }else if name == "table" && sprite.name != "Spaceship" && !construireMur
                        {
                            sprite.xScale = 0.5
                            sprite.yScale = 0.5
                            sprite.position = location
                            
                            self.addChild(sprite.copy() as! SKNode)
                            
                            // jouer un son
                            AudioServicesPlaySystemSound(sonObjSurTable);
                        }else if name == "load_select"
                        {
                            nodesSelected = savedSelected
                            if nodesSelected.count > 0
                            {
                                for node in nodesSelected
                                {
                                    node.alpha = 0.5
                                }
                                selection = true
                                updateVisibiliteCorbeille()
                            }
                        }
                    }
                }else
                {
                    cliqueAutreQueBouton(touchedNode)
                }
            }else
            {
                cliqueAutreQueBouton(touchedNode)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if construireMur {
            let touch = touches.first
            
            let position2 = touch!.locationInNode(self)
            
            CGPathAddLineToPoint(chemin, nil, position2.x, position2.y)
            CGPathCloseSubpath(chemin)
            
            let line = SKShapeNode()
            line.path = chemin
            line.strokeColor = UIColor.blackColor()
            line.lineWidth = 5
            line.name = "mur"
            
            self.addChild(line)
            
            !construireMur
        }
        
        
    }
    
    func cliqueAutreQueBouton(touchedNode: SKNode){
        //TODO: Faire une deuxième array pour les SKShape nodes et faire le meme test
        //      pour ajouter un mur à une sélection dans un array de shapes.
        if let objSelectionne = touchedNode as? SKSpriteNode
        {
            if nodesSelected.contains(objSelectionne)
            {
                nodesSelected = nodesSelected.filter {$0 != objSelectionne}
                objSelectionne.alpha = 1
                if nodesSelected.isEmpty
                {
                    selection = false
                    updateVisibiliteCorbeille()
                }
            }else
            {
                objSelectionne.alpha = 0.5
                nodesSelected.append(objSelectionne)
                selection = true
                updateVisibiliteCorbeille()
            }
            // jouer un son
            AudioServicesPlaySystemSound(sonSelection);
        }
    }
    
    func updateVisibiliteCorbeille(){
        if selection
        {
            self.childNodeWithName("boutonDelete")?.alpha = 1
        }else
        {
            self.childNodeWithName("boutonDelete")?.alpha = 0
        }
    }
    
    func initLesSons(){
        let sonCorbeilleURL = NSBundle.mainBundle().URLForResource("corbeille", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(sonCorbeilleURL!, &sonCorbeille)
        let sonObjSurTableURL = NSBundle.mainBundle().URLForResource("placerObjetSurTable", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(sonObjSurTableURL!, &sonObjSurTable)
        let sonSelectionOutilURL = NSBundle.mainBundle().URLForResource("SelectionOutil", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(sonSelectionOutilURL!, &sonSelectionOutil)
        let sonSelectionURL = NSBundle.mainBundle().URLForResource("Selection", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(sonSelectionURL!, &sonSelection)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
}
