//
//  Extensions.swift
//  Projet3
//
//  Created by David Gourde on 15-11-14.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import Foundation
import SpriteKit

enum typeObj{
    case objet
    case boutonObjet
    case autre
}

extension CGPoint {
    ///Fonction qui calcule la distance entre deux points
    func distance(point: CGPoint) -> CGFloat {
        return abs(CGFloat(hypotf(Float(point.x - x), Float(point.y - y))))
    }
    
    ///Fonction qui calcule l'angle entre deux points
    func angle(point: CGPoint) -> CGFloat {
        return atan2(point.y - y, point.x - x)
    }
    
    ///Fonction qui retourne le point au centre de deux points
    func centre(point: CGPoint) -> CGPoint {
        return CGPoint(x: (point.x - x)/2 + x, y: (point.y - y)/2 + y)
    }
}