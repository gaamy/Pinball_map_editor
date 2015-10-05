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
    var selection = false
    var sprite = SKSpriteNode()
    //Les variables de son
    var sonCorbeille: SystemSoundID = 0
    var sonObjSurTable: SystemSoundID = 0
    var sonSelectionOutil: SystemSoundID = 0
    var sonSelection: SystemSoundID = 0
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        sprite.name = "Spaceship"
        initLesSons()
        updateVisibiliteCorbeille()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)

            if let name = touchedNode.name
            {
                if selection
                {
                    selection = false
                    updateVisibiliteCorbeille()
                    if name == "boutonDelete"
                    {
                        for node in nodesSelected
                        {
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
                }else
                {
                    if name == "bouton-flipper-l"
                    {
                        sprite = SKSpriteNode(imageNamed:"flipper-l")
                        sprite.name = "flipper-l"
                        // jouer un son
                        AudioServicesPlaySystemSound(sonSelectionOutil);
                    }else if name == "bouton-flipper-r"
                    {
                        sprite = SKSpriteNode(imageNamed:"flipper-r")
                        sprite.name = "flipper-r"
                        // jouer un son
                        AudioServicesPlaySystemSound(sonSelectionOutil);
                    }else if name == "table" && sprite.name != "Spaceship"
                    {
                        sprite.xScale = 0.5
                        sprite.yScale = 0.5
                        sprite.position = location
                        
                        self.addChild(sprite.copy() as! SKNode)
                        
                        // jouer un son
                        AudioServicesPlaySystemSound(sonObjSurTable);
                    }
                }
            }else
            {
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
