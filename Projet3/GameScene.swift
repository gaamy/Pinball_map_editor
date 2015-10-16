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
    var deplacement = false
    var nodeQuiSeDeplace = SKSpriteNode()
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
        "boutontrou",
        "boutondeplacement"]
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
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            
            if listeDesObjets.contains(touchedNode.name!)
            {
                if let monNode = touchedNode as? SKSpriteNode
                {
                    nodeQuiSeDeplace = monNode
                }
            }
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            //Ne permet que le déplacement d'un node a la fois pour le moment
            //Autre bug: Si on bouge trop vite, le touch sort de l'objet et ça marche pas
            if let nomDuNode = nodeQuiSeDeplace.name
            {
                if listeDesObjets.contains(nomDuNode) && !construireMur
                {
                    nodeQuiSeDeplace.position = location
                    deplacement = true
                }
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
        
        if deplacement
        {
            deplacement = false
            nodeQuiSeDeplace = SKSpriteNode()
        }else
        {
            
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
                                
                                cliqueSurBoutonObj(name)
                            }
                        }else
                        {
                            if !cliqueSurBoutonObj(name) && name == "table" && sprite.name != "Spaceship" && !construireMur
                            {
                                sprite.xScale = 0.5
                                sprite.yScale = 0.5
                                sprite.position = location
                                
                                sprite.physicsBody = SKPhysicsBody.init(texture: sprite.texture!, alphaThreshold: 0.5, size: sprite.size)
                                
                                sprite.physicsBody?.affectedByGravity = false
                                sprite.physicsBody?.allowsRotation = false
                                
                                
                                self.addChild(sprite.copy() as! SKSpriteNode)
                                
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
                        cliqueAutreQueBouton(touchedNode, location: location)
                    }
                }else
                {
                    cliqueAutreQueBouton(touchedNode, location: location)
                }
            }
        }
    }
    
    func cliqueSurBoutonObj(name: String) -> Bool{
        if listeDesBoutons.contains(name){
            construireMur = false
            let nomObjet = name.substringFromIndex(name.startIndex.advancedBy(6))
            sprite = SKSpriteNode(imageNamed: nomObjet)
            sprite.name = nomObjet
            // jouer un son
            AudioServicesPlaySystemSound(sonSelectionOutil);
            return true
        }
        return false
    }
    
    func cliqueAutreQueBouton(touchedNode: SKNode, location: CGPoint){
        
        if let objSelectionne = touchedNode as? SKSpriteNode
        {
            if touchedNode.containsPoint(location){
                
            let unPetitTest: CGRect = objSelectionne.calculateAccumulatedFrame()
            if (CGRectContainsPoint(unPetitTest, location)){
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
