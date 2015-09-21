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
    var nodeSelected = SKSpriteNode()
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
                nodeSelected.alpha = 1
                selection = false
                
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
                }else if name == "boutonDelete"
                {
                    nodeSelected.removeFromParent()
                    
                    // Play
                    AudioServicesPlaySystemSound(mySound);
                }
            }else
            {
                if let objSelectionne = touchedNode as? SKSpriteNode
                {
                    if nodeSelected != objSelectionne
                    {
                        selection = true
                    }else
                    {
                        selection = !selection
                    }
                    nodeSelected.alpha = 1
                    nodeSelected = objSelectionne
                    
                    if selection
                    {
                        nodeSelected.alpha = 0.5
                    }else{
                        nodeSelected.alpha = 1
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
