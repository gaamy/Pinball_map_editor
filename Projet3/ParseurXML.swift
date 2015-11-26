//
//  ParseurXML.swift
//  NSXMLparser_tutorial
//
//  Created by Gabriel Amyot on 2015-11-20.
//  Copyright © 2015 tutorials. All rights reserved.
//

import Foundation

class ParseurXML :NSObject, NSXMLParserDelegate, NSFileManagerDelegate{
    ///Constantes utilises par le parseur
    ///-Nom du fichier de sauvegarde
    let sauvegardes = "sauvegardes"
    ///-URL vers "Document Directory" (Dossier reserve  pour les donnes de l'utilisateur de l'application)
    let documentDirectory = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    ///-URL vers le dossier de sauvegardes
    private var sauvegardesUrl : NSURL!
    ///-Liste des fichier presents dans le fichir sauvegard
    var fichiersSauvegardeURLs = [NSURL]()
 
    ///xml
    var xmlParser : NSXMLParser!
    //file manenger
    let fileManager = NSFileManager.defaultManager()
    
    override init(){
        super.init()
        ///initialiser le fichier de sauvegarde
        sauvegardesUrl = documentDirectory.URLByAppendingPathComponent(sauvegardes)
        
        
        ///Creation du Dossier de sauvegarde si il n'existe pas
        if !fileManager.fileExistsAtPath(sauvegardesUrl.path!){
            do{
                try fileManager.createDirectoryAtPath(sauvegardesUrl.path!, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError{
                print("error ocured crating a new file \(error)")
            }
        }
        
        ///Lister les fichiers existants
        fichiersSauvegardeURLs = getLocalSavedFiles()
        
        
    }
    
    
    //TODO: Refactor this function, its more like a workbech whit a lot a experiments
    //Vas chercher le fichier xml au path specifie
    func parseXMLFile(nomFichier : String) {

        URLActuel = sauvegardesUrl.URLByAppendingPathComponent(nomFichier)
        ///extrias les donnes du fichier
        if fileManager.fileExistsAtPath(URLActuel.path!){
            let dataBuffer = fileManager.contentsAtPath(URLActuel.path!)
       
            self.xmlParser = NSXMLParser(data: dataBuffer!)
            self.xmlParser.delegate = self
            self.xmlParser.parse()
        }else{
        print("file not found")
        }
    }
    
    ///Sauvegarde une carte sous format string dans le dossier "sauvegardes" sous le nom de nomFichier
    func sauvegarderStringXML( stringData: NSString, nomFichier :String ) -> Bool{
        
        //TODO:verifier si le fichier existe
        //TODO: gerer les cas de modification (a tester)
        
        ///Transforme le string XML en NSData
        let data = stringData.dataUsingEncoding(NSUTF8StringEncoding)
        
        ///Cree le url vers le fichier
        let fichierUrl = sauvegardesUrl.URLByAppendingPathComponent(nomFichier)
        
        ///sauvegarde le NSData
        if data!.writeToURL(fichierUrl, atomically: true) {
            print("fichier sauvegarde correctement")
            return true
        }else{
            return false
            
        }
    }
    
    
    ///Recupereles fichiers das le dossier "<application folder>/Documents/sauvegardes"
    func getLocalSavedFiles() -> [NSURL]{
        let fichiersTrouves = fileManager.enumeratorAtPath(sauvegardesUrl.path!)
        
        var savedFiles = [NSURL]()
        
        if fichiersTrouves != nil{
            
            ///itere atravers les fichiers
            for nomFichier in fichiersTrouves!{
                if (nomFichier as! String) != ".DS_Store"{
                    ///cree un nouveau NSURL a partir du path de sauvegarde et du nom du fichier
                    let URLFichier = sauvegardesUrl.URLByAppendingPathComponent(nomFichier as! String)
                    savedFiles.append(URLFichier)
                }
            }
        }
        return savedFiles
    }
    
    
    //path de la carte acuelle
    private var URLActuel: NSURL!
    ///Table de jeux
    var carteActuelle : Carte!
    

    
    ///Parseur XML  didStartElement: quand un élément XML est trouvé
    ////C'est ici que les structures et les objets doivent etre crees
    ////Atributs: Les atributs d'elements saont egalement traites ici
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        //TODO: ajouter Error handling: quand un atribut n'est pas trouve dans l'element, une erreur se declanche
        
        switch elementName {
        case "xml": break
            
        case "jeu":
            //TODO: enrregistrer le nom de la carte dans l'objet Carte
            //STUB: nomFichier
            let nomFichier = URLActuel.lastPathComponent!
            carteActuelle = Carte(nom: nomFichier)
            
        case "arbre":
            carteActuelle.arbre = Arbre()
            
        case "propriete": break
            
        ///elements de l'Arbre
        case "table":
            let potiontionX = attributeDict["positionx"] as String!
            let potiontionY = attributeDict["positiony"] as String!
            carteActuelle.arbre.ajouterTable(Int(potiontionX)!, posY: Int(potiontionY)!)
            
        case "mur":
            let positionX = attributeDict["positionx"] as String!
            let positionY = attributeDict["positiony"] as String!
            let largeurMur = attributeDict["largeurMur"] as String!
            let angle = attributeDict["angleRotation"] as String!
            carteActuelle.arbre.ajouterMur(Int(positionX)!, posY: Int(positionY)!, largeurMur: Float(largeurMur)!, angleRotation: Float(angle)!)
            
            ///Pour l'instant, les portails sont stoqu comme nimporte quel qutre objet sans consiterer qui son pairs
        case "portail":
            var temp = attributeDict["positionx"] as String!
            let positionX = Int(temp!)!
            temp = attributeDict["positiony"] as String!
            let positionY = Int(temp!)!
            temp = attributeDict["echelle"] as String!
            let echelle = Float(temp!)!
            temp = attributeDict["angleRotation"] as String!
            let angle = Float(temp!)!
            
            carteActuelle.arbre.ajouterPortail(positionX, posY: positionY, echellePortail: echelle, angleRotation: angle)
        
        ///elements de Proprietes
        case "ButoirCirculair":
            let points = attributeDict["point"] as String!
            carteActuelle.proprietes.setPointageButoirCirculaire(Int(points)!)
            
        case "ButoirTriangulair":
            let points = attributeDict["point"] as String!
            carteActuelle.proprietes.setPointageButoirTriangulaire(Int(points)!)
            
        case "Cible":
            let points = attributeDict["point"] as String!
            carteActuelle.proprietes.setPointageCible(Int(points)!)
            
        case "passezNiveau" :
            let points = attributeDict["point"] as String!
            carteActuelle.proprietes.setPointagePourPasserNiveau(Int(points)!)
            
        //Il y a un erreur dan le nom de cet attribue pour respecter lerreur dans le xml du client lourd
        case "Billegratuite":
            let points = attributeDict["point"] as String!
            carteActuelle.proprietes.setPointagePourBillegratuite(Int(points)!)
            
        case "NiveauDiffulte":
            let difficulte = attributeDict["point"] as String!
            carteActuelle.proprietes.setDifficulte(Int(difficulte)!)
        
        default:
            var temp = attributeDict["positionx"] as String!
            let positionX = Int(temp!)!
            temp = attributeDict["positiony"] as String!
            let positionY = Int(temp!)!
            temp = attributeDict["echelle"] as String!
            let echelle = Float(temp!)!
            temp = attributeDict["angleRotation"] as String!
            let angle = Float(temp!)!
            
            carteActuelle.arbre.ajouterAutreObjet(elementName, posX: positionX, posY: positionY, echelleObjet: echelle, angleRotation: angle)
        }
    }
    
    
    ///Function that capture the information between the didStartElement and didEndElement
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        
    }
    
    ///methode declanche quand une tag te fermeture </> est rencontre. represente la fin d'un element
    ///
    ///cest ici que nous devons attribuer les classes crees a leur contenuers respectifs
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        
        if elementName == "jeu"{
            //cartes.append(carteActuelle)
            print(carteActuelle.toXmlString())
        }
        
    }
    
    ///Apele quand il y aune erreur dans le parseur
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print("Erreur dans le parseur XML")
    }
    

    
}



