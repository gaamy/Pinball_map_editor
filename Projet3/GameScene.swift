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
    let sonCorbeilleURL = NSBundle.mainBundle().URLForResource("corbeille", withExtension: "mp3")
    var sonCorbeille: SystemSoundID = 0
    let sonObjSurTableURL = NSBundle.mainBundle().URLForResource("placerObjetSurTable", withExtension: "mp3")
    var sonObjSurTable: SystemSoundID = 1
    let sonSelectionOutilURL = NSBundle.mainBundle().URLForResource("SelectionOutil", withExtension: "mp3")
    var sonSelectionOutil: SystemSoundID = 2
    let sonSelectionURL = NSBundle.mainBundle().URLForResource("Selection", withExtension: "mp3")
    var sonSelection: SystemSoundID = 3
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        sprite.name = "Spaceship"
        AudioServicesCreateSystemSoundID(sonCorbeilleURL!, &sonCorbeille)
        AudioServicesCreateSystemSoundID(sonObjSurTableURL!, &sonObjSurTable)
        AudioServicesCreateSystemSoundID(sonSelectionOutilURL!, &sonSelectionOutil)
        AudioServicesCreateSystemSoundID(sonSelectionURL!, &sonSelection)
        
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
                        // jouer un son
                        AudioServicesPlaySystemSound(sonSelectionOutil);
                    }else if name == "bouton-flipper-r"
                    {
                        sprite = SKSpriteNode(imageNamed:"flipper-r")
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
                        }
                    }else
                    {
                        objSelectionne.alpha = 0.5
                        nodesSelected.append(objSelectionne)
                        selection = true
                    }
                    // jouer un son
                    AudioServicesPlaySystemSound(sonSelection);
                    
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if selection
        {
            self.childNodeWithName("boutonDelete")?.alpha = 1
        }else
        {
            self.childNodeWithName("boutonDelete")?.alpha = 0
        }
    }
}
