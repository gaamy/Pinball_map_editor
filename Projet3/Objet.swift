//
//  Objet.swift
//  Projet3
//
//  Created by David Gourde on 15-11-04.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import Foundation
import SpriteKit

class Objet: SKSpriteNode {
    //Propriétés additionnelles
    var points  = 100 //Valeur des points donnée par une cible par défaut
    var type = typeObj.autre
    
    func copier() -> Objet {
        let objectCopy = Objet()
        objectCopy.points = points
        objectCopy.type = type
        
        objectCopy.physicsBody = physicsBody
        
        objectCopy.name = name
        objectCopy.texture = texture
        objectCopy.position.x = position.x
        objectCopy.position.y = position.y
        objectCopy.zPosition = zPosition
        
        objectCopy.zRotation = zRotation
        objectCopy.zRotation = zRotation
        objectCopy.size = size
        return objectCopy
    }
    
    func duppliquer() -> Objet {
        let objectCopy = Objet()
        objectCopy.points = points
        objectCopy.type = type
        
        objectCopy.name = name
        objectCopy.texture = texture
        objectCopy.position.x = position.x + size.height/2
        objectCopy.position.y = position.y + size.width/2
        objectCopy.zPosition = zPosition
        
        objectCopy.zRotation = zRotation
        objectCopy.zRotation = zRotation
        objectCopy.size = size
        return objectCopy
    }
}