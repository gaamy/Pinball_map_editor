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
    var premierPortail: Bool
    
    init(noeud: SKSpriteNode){
        self.noeud = noeud
        scale = 5
        positionSurTableAvantZoom = CGPoint()
        premierPortail = false
    }
    
    init(noeud: SKSpriteNode, premierPortail: Bool){
        self.noeud = noeud
        scale = 5
        positionSurTableAvantZoom = CGPoint()
        self.premierPortail = premierPortail
    }
}