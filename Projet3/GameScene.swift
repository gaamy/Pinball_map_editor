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
    let soundURL = NSBundle.mainBundle().URLForResource("camera_single_shot_of_35_mm_automatic_camera", withExtension: "mp3")
    var mySound: SystemSoundID = 0
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        sprite.name = "Spaceship"
        AudioServicesCreateSystemSoundID(soundURL!, &mySound)
        
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
                        
                        // Play
                        AudioServicesPlaySystemSound(mySound);
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
                    }else if name == "bouton-flipper-r"
                    {
                        sprite = SKSpriteNode(imageNamed:"flipper-r")
                    }else if name == "table" && sprite.name != "Spaceship"
                    {
                        sprite.xScale = 0.5
                        sprite.yScale = 0.5
                        sprite.position = location
                        
                        self.addChild(sprite.copy() as! SKNode)
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
