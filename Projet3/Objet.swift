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
    var points: Int
    var scale: CGFloat
    var positionSurTableAvantZoom: CGPoint
    
    init(noeud: SKSpriteNode){
        self.noeud = noeud
        points = 100
        scale = 1
        positionSurTableAvantZoom = CGPoint()
    }
    
    init(noeud: SKSpriteNode, points: Int){
        self.noeud = noeud
        self.points = points
        scale = 1
        positionSurTableAvantZoom = CGPoint()
    }
}