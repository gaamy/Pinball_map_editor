//
//  Carte.swift
//  NSXMLparser_tutorial
//
//  Created by Gabriel Amyot on 2015-11-10.
//  Copyright © 2015 tutorials. All rights reserved.
//

import Foundation

///Carte de jeux
class Carte {
    
    //date de sauvegarde
    var date : String
    var time : String
    
    // Nom sous lequel la carte est erregistre
    var nomFichier : String
    //Arbre contenant les objets de la table de jeux
    var arbre = Arbre()
    //Proprietes de la table de jeux
    var proprietes = Proprietes()
    
    
    //Dictionnaire utiliser pour traduire les noms du cote client leger
    //La clée correspond au nom de l'objet sur le xml/ client lourd, et la valeur au nom du cote client leger
    let dictionnaireObjetsXmlToLeger = ["cible":"cible", "butoirTriangulaireDroit":"butoirTriDroit","butoirTriangulaireGauche":"butoirTriGauche", "butoirCirculaire":"butoirCirc","generateurDeBilles":"generateur", "paletteGauche1":"paletteGauche1", "paletteGauche2":"paletteGauche2", "paletteDroite1":"paletteDroite1", "paletteDroite2":"paletteDroite2", "trou":"trou", "ressort":"ressort", "accelerateur":"accelerateur", "mur":"mur","portail":"portail", "destructeur":"destructeur"]
    
    let dictionnaireObjetsLegerToXml = ["cible":"cible", "butoirTriDroit":"butoirTriangulaireDroit","butoirTriGauche":"butoirTriangulaireGauche", "butoirCirc":"butoirCirculaire","generateur":"generateurDeBilles", "paletteGauche1":"paletteGauche1", "paletteGauche2":"paletteGauche2", "paletteDroite1":"paletteDroite1", "paletteDroite2":"paletteDroite2", "trou":"trou", "ressort":"ressort", "accelerateur":"accelerateur", "mur":"mur","portail":"portail", "destructeur":"destructeur"]
    

    ///Constructeur
    init(nom : String, date: String, time: String){
        nomFichier = nom
        self.date = date
        self.time = time
    }
    
    ///Getters
    func getNom() -> String{
        return nomFichier
    }
    
    func getArbre() -> Arbre{
        return arbre
    }
    
    func getProprietes() -> Proprietes{
        return proprietes
    }
    
    //setter
    func setNom(nouveauNom:String){
        self.nomFichier = nouveauNom
    }
    
    ///verifier si la care de jeux poseder au moin : generateur de bille, trou,table
    func verifierValidite() -> Bool{
        var trouPresent = false
        var generateurPresent = false
        var ressortPresent = false

        
        for objet in self.arbre.autresObjets{
            switch objet.type!{
                case "trou":
                    trouPresent = true
                case "generateurDeBilles":
                    generateurPresent = true
                case "ressort":
                    ressortPresent = true
                default: break
            }
            
        }
        
        if trouPresent && generateurPresent && ressortPresent{
            return true
        }
        return false
    }
    
    ///Imprime la carte en format xml
    func toXmlString() -> NSString!{
        if !verifierValidite(){
            print("Carte invalide, elle ne peux etre sauvegarde ")
            return nil
        }
        
        
        let sauvegardeCarte = AEXMLDocument()
        
        //jeux
        let attributsJeux = ["Date" : "\(self.date)", "Heure" : "\(self.time)"]
        let jeuxXml = sauvegardeCarte.addChild(name: "jeu", attributes: attributsJeux)
        
        
        let arbreXml = jeuxXml.addChild(name: "arbre")
        let proprieteXml = jeuxXml.addChild(name: "propriete")
        
        
        ///table
        let attributsTable = ["positionx": "\((self.arbre.table?.positionX)!)" ,"positiony": "\((self.arbre.table?.positionY)!)"]
        arbreXml.addChild(name:"table",attributes: attributsTable)
        
        ///portail
        for objet in self.arbre.portail{
            let attributs = ["positionx" : "\(objet.positionX!)", "positiony" : "\(objet.positionY!)", "echelle" : "\(objet.echelle!)", "angleRotation" : "\(objet.angleRotation!)"]
            arbreXml.addChild(name:"\(objet.type!)",attributes: attributs)
        }
        
        ///mur
        for objet in self.arbre.mur{
            let attributs = ["positionx" : "\(objet.positionX!)", "positiony" : "\(objet.positionY!)", "largeurMur" : "\(objet.largeurMur!)", "angleRotation" : "\(objet.angleRotation!)"]
            arbreXml.addChild(name:"\(objet.type!)",attributes: attributs)
        }
        
        ///AutresObjets
        for objet in self.arbre.autresObjets{
            let attributs = ["positionx" : "\(objet.positionX!)", "positiony" : "\(objet.positionY!)", "echelle" : "\(objet.echelle!)", "angleRotation" : "\(objet.angleRotation!)"]
            arbreXml.addChild(name:"\(objet.type!)",attributes: attributs)
        }
        
        ///proprites
        proprieteXml.addChild(name: "ButoirCirculair", attributes: ["point":"\((self.proprietes.pointageButoirCirculaire)!)"])
        proprieteXml.addChild(name: "ButoirTriangulair", attributes: ["point":"\((self.proprietes.pointageButoirTriangulaire)!)"])
        proprieteXml.addChild(name: "Cible", attributes: ["point":"\((self.proprietes.pointageCible)!)"])
        proprieteXml.addChild(name: "passezNiveau", attributes: ["point":"\((self.proprietes.pointagePourPasserNiveau)!)"])
        proprieteXml.addChild(name: "Billegratuite", attributes: ["point":"\((self.proprietes.pointagePourBillegratuite)!)"])
        proprieteXml.addChild(name: "NiveauDiffulte", attributes: ["point":"\((self.proprietes.niveauDiffulte)!)"])
        
        return sauvegardeCarte.xmlString
    }
}

///Proprietes de la carte
class Proprietes{
    var pointageButoirCirculaire : Int?
    var pointageButoirTriangulaire : Int?
    var pointageCible : Int?
    var pointagePourPasserNiveau : Int?
    var pointagePourBillegratuite : Int?
    var niveauDiffulte : Int?

    
    ///Setters pour les proprietes
    func setPointageButoirCirculaire(points : Int){
        pointageButoirCirculaire = points
    }
    func setPointageButoirTriangulaire(points : Int){
        pointageButoirTriangulaire = points
    }
    func setPointageCible(points : Int){
        pointageCible = points
    }
    func setPointagePourPasserNiveau(points : Int){
        pointagePourPasserNiveau = points
    }
    func setPointagePourBillegratuite(points : Int){
        pointagePourBillegratuite = points
    }
    func setDifficulte(difficulte : Int){
        niveauDiffulte = difficulte
    }

}

///Arbre contenant tout les objets du jeux
class Arbre {
    internal var table : ObjetDeScene?
    var autresObjets = Array<AutreObjetDeScene>()
    var mur = Array<Mur>()
    var portail = Array<AutreObjetDeScene>()

    
    ///Setter pour table
    func ajouterTable(posX : Int, posY : Int){
        table =  ObjetDeScene(type:"table", x:posX, y:posY)
    }
    
    ///Setter pour le mur
    func ajouterMur(posX : Int, posY : Int, largeurMur : Float, angleRotation : Float){
        mur.append(Mur(typeObj:"mur", x:posX, y:posY, largeur:largeurMur, angle: angleRotation))
    }
    
    ///Setter pour portail
    func ajouterPortail(posX : Int, posY : Int, echellePortail : Float, angleRotation : Float){
        portail.append(AutreObjetDeScene(typeObj:"portail", x:posX, y:posY, echelleObj:echellePortail, angle: angleRotation))
    }
    
    func ajouterAutreObjet(nom:String, posX : Int, posY : Int, echelleObjet : Float, angleRotation : Float){
        autresObjets.append(AutreObjetDeScene(typeObj: nom, x: posX, y: posY, echelleObj: echelleObjet, angle: angleRotation))
    }
}



///classe de base pour un objet de scene
/// obs: la "table" est le seul objet instancié directement a partir de AutreObjetDeScene
class ObjetDeScene{
    init (type : String, x : Int, y : Int){
        self.type = type
        self.positionX = x
        self.positionY = y
    }
    
    var type : String?
    var positionX  : Int?
    var positionY  : Int?
}

///Spécification de ObjetDeScene pour un mur
class Mur : ObjetDeScene{
    init(typeObj : String, x : Int, y : Int, largeur: Float, angle: Float){
        
        super.init(type: typeObj,x: x,y: y)
        largeurMur = largeur
        angleRotation = angle
    }
    
    var largeurMur :Float?
    var angleRotation :Float?
    
}




///Spécification de ObjetDeScene pour tout les autres objets ObjetDeScene
class AutreObjetDeScene : ObjetDeScene{
    init(typeObj : String, x : Int, y : Int, echelleObj: Float, angle: Float){
      
        super.init(type: typeObj,x: x,y: y)
        echelle = echelleObj
        angleRotation = angle
    }
    
    var echelle : Float?
    var angleRotation : Float?
}


