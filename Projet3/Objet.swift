//
//  Objet.swift
//  Projet3
//
//  Created by David Gourde on 15-11-17.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import SpriteKit
import Foundation

class monObjet {
    var noeud: SKSpriteNode
    var scale: CGFloat
    var positionSurTableAvantZoom: CGPoint
    
    init(noeud: SKSpriteNode){
        self.noeud = noeud
        scale = 1
        positionSurTableAvantZoom = CGPoint()
    }
    
    init(noeud: SKSpriteNode, points: Int){
        self.noeud = noeud
        scale = 1
        positionSurTableAvantZoom = CGPoint()
    }
}