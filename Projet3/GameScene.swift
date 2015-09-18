//
//  GameScene.swift
//  Projet3
//
//  Created by David Gourde on 2015-09-15.
//  Copyright (c) 2015 David Gourde. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = SKColor(red: 104, green:0, blue:0, alpha: 1.0)
        let myLabel = SKLabelNode(fontNamed:"Arial")
        myLabel.text = "Éditeur de zone";
        myLabel.fontSize = 40;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame)-40);
        
        self.addChild(myLabel)
        
        var button = SKSpriteNode(imageNamed: "bouton-flipper-l")
        button.position = CGPointMake(CGRectGetMinX(self.frame)+button.size.width, CGRectGetMidY(self.frame))
        button.name = "bouton-flipper-l"
        
        self.addChild(button)
        
        button = SKSpriteNode(imageNamed: "bouton-flipper-r")
        button.position = CGPointMake(CGRectGetMinX(self.frame)+button.size.width, CGRectGetMidY(self.frame)+button.size.height)
        button.name = "bouton-flipper-r"
        
        self.addChild(button)
        
    }
    var sprite = SKSpriteNode(imageNamed:"Spaceship")
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)

            if let name = touchedNode.name
            {
                if name == "bouton-flipper-l"
                {
                    sprite = SKSpriteNode(imageNamed:"flipper-l")
                }else if name == "bouton-flipper-r"
                {
                    sprite = SKSpriteNode(imageNamed:"flipper-r")
                }
            }else{
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            self.addChild(sprite.copy() as! SKNode)
            }
            
            
        }
    }
    
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
