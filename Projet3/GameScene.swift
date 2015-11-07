//
//  GameScene.swift
//  Projet3
//
//  Created by David Gourde on 2015-09-15.
//  Copyright (c) 2015 David Gourde. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, UITextFieldDelegate {
    //Variables pour les labels
    var labelPosition:SKLabelNode?
    var textPositionX:UITextField?
    var textPositionY:UITextField?
    
    //Variables globale à la classe
    var viewController: UIViewController? //Identifie le menuPrincipal
    var table = SKNode()
    var nodesSelected = [SKSpriteNode]()
    var savedSelected = [SKSpriteNode]()
    var selection = false
    var sprite = Objet()
    var construireMur = false
    let chemin = CGPathCreateMutable()
    var murTemp = SKNode()
    var deplacement = false
    var nodeQuiSeDeplace = SKSpriteNode()
    var endroitPrecedent = CGPoint()
    //Les variables de son
    var sonCorbeille: SystemSoundID = 0
    var sonObjSurTable: SystemSoundID = 0
    var sonSelectionOutil: SystemSoundID = 0
    var sonSelection: SystemSoundID = 0
    
    //Variables pour la rotation des objets
    var offset:CGFloat = 0
    var theRotation:CGFloat = 0
    
    //Les listes de noms
    let listeDesBoutons = [
        "boutonaccelerateur",
        "boutonbutoirCirc",
        "boutonbutoirTriDroit",
        "boutonbutoirTriGauche",
        "boutoncible",
        "boutondestructeur",
        "boutongenerateur",
        "boutonpaletteDroite1",
        "boutonpaletteDroite2",
        "boutonpaletteGauche1",
        "boutonpaletteGauche2",
        "boutonportail",
        "boutonressort",
        "boutontrou",
        "boutondeplacement"]
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        sprite.name = "Spaceship"
        initLesSons()
        updateVisibiliteCorbeille()
        
        self.view!.multipleTouchEnabled = true
        self.view!.userInteractionEnabled = true
        
        //Mon gesture pour changer la taille
        let gestureRec1 = UIPinchGestureRecognizer(target: self, action: "tailleDeLObjet:")
        self.view!.addGestureRecognizer(gestureRec1)
        
        //Mon gesture pour la rotation
        let gestureRec2 = UIRotationGestureRecognizer(target: self, action: "rotationDeLObjet:")
        self.view!.addGestureRecognizer(gestureRec2)
        
        //On initialise la variable table pour utilisation facile dans la classe
        table = self.childNodeWithName("table")!
        
        //Les labels et text fields
        labelPosition = SKLabelNode(fontNamed: "Arial")
        labelPosition!.text = "Position (x,y)"
        labelPosition!.position = CGPoint(x: CGRectGetMaxX(self.frame)-200, y: CGRectGetMidY(self.frame)+185)
        labelPosition!.fontSize = 15
        self.addChild(labelPosition!)
        
        textPositionX = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMidY(self.frame)-200, width: 50, height: 20))
        self.view!.addSubview(textPositionX!)
        textPositionX!.backgroundColor = UIColor.grayColor()
        textPositionX!.delegate = self
        
        textPositionY = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMidY(self.frame)-200, width: 50, height: 20))
        self.view!.addSubview(textPositionY!)
        textPositionY!.backgroundColor = UIColor.grayColor()
        textPositionY!.delegate = self
    }
    
    func tailleDeLObjet(sender: UIPinchGestureRecognizer){
        if (sender.state == .Began){
            //On fait ici ce qu'on veut qui se passe quand le pincement débute
            print("Debut du pincement")
        }
        if sender.state == .Changed {
            //Pendant la le pincement
            
            if nodesSelected.count > 0 {
                //TODO, on doit aussi scale la boite englobante**
                for node in nodesSelected{
                    node.size.width = node.size.width * sender.scale
                    node.size.height = node.size.height * sender.scale
                    node.physicsBody = SKPhysicsBody.init(texture: sprite.texture!, size: sprite.size)
                }
                sender.scale = 1
            }else{
                //Ici on scale la vue au complet (zoom)
                //TODO: Ajouter un max et un min au scale de la scène
                self.view!.transform = CGAffineTransformScale(self.view!.transform, sender.scale, sender.scale)
                sender.scale = 1
            }
        }
        if sender.state == .Ended {
            //Après le pincement
            print("Fini de pincer")
        }
    }
    
    func rotationDeLObjet(sender: UIRotationGestureRecognizer){
        if (sender.state == .Began){
            //On fait ici ce qu'on veut qui se passe quand la rotation débute
            if nodesSelected.count > 1 {
                var maxX = nodesSelected[0].position.x
                var minX = nodesSelected[0].position.x
                var maxY = nodesSelected[0].position.y
                var minY = nodesSelected[0].position.y
                
                for node in nodesSelected{
                    if node.position.x > maxX{
                        maxX = node.position.x
                    }
                    if node.position.x < minX{
                        minX = node.position.x
                    }
                    if node.position.y > maxY{
                        maxY = node.position.y
                    }
                    if node.position.y > maxY{
                        minY = node.position.y
                    }
                }
                
                let centre = CGPoint(x: (maxX-minX)/2+minX, y: (maxY-minY)+minY/2)
                
                //print("x: \((maxX-minX)/2+minX) y: \((maxY-minY)+minY/2)")
                
                let nodeCentre = SKNode()
                nodeCentre.position = centre
                nodeCentre.name = "nodeCentre"
                self.addChild(nodeCentre)
                
                for node in nodesSelected
                {
                    //node.removeFromParent()
                    //self.childNodeWithName("nodeCentre")?.addChild(node)
                    node.anchorPoint = centre
                }
            }
        }
        if sender.state == .Changed {
            //TODO: On doit pouvoir faire une rotation multiple à partir du centre de tous les objets
            
            //Pendant la rotation
            theRotation = CGFloat(sender.rotation) + self.offset
            theRotation = theRotation * -1
            
            //Si une seule node, on la rotate normalement
            if nodesSelected.count == 1 {
                nodesSelected[0].zRotation = theRotation
            }else if nodesSelected.count > 1 {
                //self.childNodeWithName("nodeCentre")?.zRotation = theRotation
                for node in nodesSelected
                {
                    node.zRotation = theRotation
                }
            }
        }
        if sender.state == .Ended {
            //Après la rotation
            self.offset = theRotation * -1
            
            for node in nodesSelected
            {
                //node.removeFromParent()
                //self.addChild(node)
            }
            
            //self.childNodeWithName("nodeCentre")?.removeFromParent()
            
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        //débutMur
        let debutMur = touches.first
        let position1 = debutMur!.locationInNode(self)
        CGPathMoveToPoint(chemin, nil, position1.x, position1.y)
        //finMur
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            
            endroitPrecedent = location
                if table.containsPoint(touchedNode.position)
                {
                    //On cast le SKNode en SKPriteNode
                    if let monNode = touchedNode as? SKSpriteNode
                    {
                        nodeQuiSeDeplace = monNode
                    }
                }
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            //TODO: Utilisez la bounding box a la place.
            //TODO: Régler le bug qui fait que quand je fais un gesture, ça déplace les objets!!!
            if selection && nodesSelected.contains(nodeQuiSeDeplace)
            {
                    for node in nodesSelected
                    {
                            let nouvEndroit = CGPoint(x:(node.position.x + location.x - endroitPrecedent.x),y:(node.position.y + location.y - endroitPrecedent.y))
                            //TODO: On doit utiliser soit la boite englobante ou soit les bordures des sprites
                            if surTable(nouvEndroit, node: node)
                            {
                                node.position = nouvEndroit
                            }
                    }
                    deplacement = true
                    endroitPrecedent = location
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if construireMur && !deplacement {
            let touch = touches.first
            
            let position2 = touch!.locationInNode(self)
            
            CGPathAddLineToPoint(chemin, nil, position2.x, position2.y)
            CGPathCloseSubpath(chemin)
            
            //Changer la ligne pour un sprite de la bonne taille/scale
            let line = SKShapeNode()
            line.path = chemin
            line.strokeColor = UIColor.blackColor()
            line.lineWidth = 5
            line.name = "mur"
            
            line.physicsBody = SKPhysicsBody(edgeChainFromPath: chemin)
            
            line.physicsBody?.affectedByGravity = false
            line.physicsBody?.allowsRotation = false
            //Test pour les collisions
            line.physicsBody?.categoryBitMask = 0x1
            
            self.addChild(line)
        }
        
        if deplacement
        {
            deplacement = false
            nodeQuiSeDeplace = SKSpriteNode()
        }else
        {
            for touch in (touches ) {
                let location = touch.locationInNode(self)
                let touchedNode = self.nodeAtPoint(location)
                
                if let name = touchedNode.name
                {
                    
                    if name == "boutonmenu" {
                        //TODO: Ajouter la transition vers le menu (no idea how)
                        //GABRIEL va te'l faire en trois secondes
                        
                        var vc: UIViewController = UIViewController()
                        vc = self.view!.window!.rootViewController!
                        //vc.performSegueWithIdentifier("backToMenu", sender: vc)
                        self.viewController?.performSegueWithIdentifier("backToMenu", sender: vc)
                        

                    }
                    
                    if name == "boutonmur" {
                        construireMur = true
                        // jouer un son
                        AudioServicesPlaySystemSound(sonSelectionOutil);
                    }
                    if !surTable(location, node: (touchedNode as? SKSpriteNode)!)
                    {
                        if selection
                        {
                            if name == "save_select"
                            {
                                savedSelected = nodesSelected
                            }
                            
                            if name == "same_select" && nodesSelected.count == 1
                            {
                                //On vérifie sur les enfants de la scène
                                for enfant in self.children
                                {
                                    //On retrouve le nom du node sélectionné
                                    if enfant.name == nodesSelected[0].name
                                    {
                                        if let monEnfant = enfant as? SKSpriteNode
                                        {
                                            nodesSelected.append(monEnfant)
                                            monEnfant.alpha = 0.5
                                        }
                                    }
                                }
                            }else
                            {
                                selection = false
                                updateVisibiliteCorbeille()
                                if name == "boutonDelete"
                                {
                                    //Si on delete des nodes qui sont dans la sélection sauvegardé, on ne doit pas les resélectionné lors du chargement de la séleciton (ils n'existent plus).
                                    for node in nodesSelected
                                    {
                                        savedSelected = savedSelected.filter {$0 != node}
                                        node.removeFromParent()
                                    }
                                    
                                    // jouer un son
                                    AudioServicesPlaySystemSound(sonCorbeille);
                                }
                                //On delete les nodes sélectionnés
                                for node in nodesSelected
                                {
                                    node.alpha = 1
                                }
                                nodesSelected.removeAll()
                                
                                //TODO: Vérifier si nécéssaire
                                cliqueSurBoutonObj(name)
                            }
                        }else
                        {
                            if !cliqueSurBoutonObj(name) && name == "table" && sprite.name != "Spaceship" && !construireMur
                            {
                                sprite.xScale = 0.5
                                sprite.yScale = 0.5
                                sprite.position = location
                                
                                sprite.physicsBody = SKPhysicsBody.init(texture: sprite.texture!, size: sprite.size)
                                
                                sprite.physicsBody?.affectedByGravity = false
                                sprite.physicsBody?.allowsRotation = false
                                //Était pour test, p-e pas nécéssaire anymore
                                sprite.physicsBody?.categoryBitMask = 0x1
                                
                                self.addChild(sprite.copy() as! SKSpriteNode)
                                
                                // jouer un son
                                AudioServicesPlaySystemSound(sonObjSurTable);
                            }else if name == "load_select"
                            {
                                nodesSelected = savedSelected
                                if nodesSelected.count > 0
                                {
                                    for node in nodesSelected
                                    {
                                        node.alpha = 0.5
                                    }
                                    selection = true
                                    updateVisibiliteCorbeille()
                                }
                            }
                        }
                    }else
                    {
                        cliqueAutreQueBouton(touchedNode, location: location)
                    }
                }else
                {
                    cliqueAutreQueBouton(touchedNode, location: location)
                }
            }
        }
        updateTextProprieteObjet()
    }
    
    func surTable(location: CGPoint, node: SKSpriteNode) -> Bool
    {
        let largeur = node.size.width / 2
        let hauteur = node.size.height / 2
        let gauche = CGPoint(x:location.x - largeur,y:location.y)
        let droite = CGPoint(x:location.x + largeur,y:location.y)
        let haut = CGPoint(x:location.x,y:location.y + hauteur)
        let bas = CGPoint(x:location.x,y:location.y - hauteur)
        if table.containsPoint(gauche) &&
            table.containsPoint(droite) &&
            table.containsPoint(haut) &&
            table.containsPoint(bas)
        {
            return true
        }else
        {
            return false
        }
    }

    func cliqueSurBoutonObj(name: String) -> Bool{
        if listeDesBoutons.contains(name){
            construireMur = false
            let nomObjet = name.substringFromIndex(name.startIndex.advancedBy(6))
            sprite = Objet(imageNamed: nomObjet)
            sprite.name = nomObjet
            // jouer un son
            AudioServicesPlaySystemSound(sonSelectionOutil);
            return true
        }
        return false
    }
    
    //En sélectionne ou désélectionne l'objet qu'on reçoit en parametre
    func cliqueAutreQueBouton(touchedNode: SKNode, location: CGPoint){
        //let noeud = self.physicsWorld.bodyAtPoint(location)
        //print(nodo?.node?.name)
        
        if let objSelectionne = touchedNode as? SKSpriteNode
        {
            if nodesSelected.contains(objSelectionne)
            {
                nodesSelected = nodesSelected.filter {$0 != objSelectionne}
                objSelectionne.alpha = 1
                if nodesSelected.isEmpty
                {
                    selection = false
                    updateVisibiliteCorbeille()
                }
            }else
            {
                objSelectionne.alpha = 0.5
                nodesSelected.append(objSelectionne)
                selection = true
                updateVisibiliteCorbeille()
            }
            // jouer un son
            AudioServicesPlaySystemSound(sonSelection);
            updateTextProprieteObjet()
        }
    }
    
    func updateVisibiliteCorbeille(){
        if selection
        {
            self.childNodeWithName("boutonDelete")?.alpha = 1
        }else
        {
            self.childNodeWithName("boutonDelete")?.alpha = 0
        }
    }
    
    func updateTextProprieteObjet(){
        if nodesSelected.count == 1 {
            textPositionX!.text = nodesSelected[0].position.x.description
            textPositionY!.text = nodesSelected[0].position.y.description
            
            self.textPositionX?.enabled = true
            textPositionX!.backgroundColor = UIColor.whiteColor()
            
            self.textPositionY?.enabled = true
            textPositionY!.backgroundColor = UIColor.whiteColor()
            
        }else{
            textPositionX!.text = ""
            textPositionY!.text = ""
            
            self.textPositionX?.enabled = false
            textPositionX!.backgroundColor = UIColor.grayColor()
            
            self.textPositionY?.enabled = false
            textPositionY!.backgroundColor = UIColor.grayColor()
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textPositionX!.resignFirstResponder()
        textPositionY!.resignFirstResponder()
        
        if(textPositionX!.text! != "" && textPositionY!.text! != "" && nodesSelected.count == 1){
            if let x = NSNumberFormatter().numberFromString(textPositionX!.text!) {
                if let y = NSNumberFormatter().numberFromString(textPositionY!.text!){
                    let xFloat = CGFloat(x)
                    let yFloat = CGFloat(y)
                    let point = CGPoint(x: xFloat, y: yFloat)
                    if table.containsPoint(point) {
                        nodesSelected[0].position = point
                    }else{
                        textPositionX!.text! = nodesSelected[0].position.x.description
                        textPositionY!.text! = nodesSelected[0].position.y.description
                    }
                }
            }
        }
        
        return true
    }
    
    func initLesSons(){
        let sonCorbeilleURL = NSBundle.mainBundle().URLForResource("corbeille", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(sonCorbeilleURL!, &sonCorbeille)
        let sonObjSurTableURL = NSBundle.mainBundle().URLForResource("placerObjetSurTable", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(sonObjSurTableURL!, &sonObjSurTable)
        let sonSelectionOutilURL = NSBundle.mainBundle().URLForResource("SelectionOutil", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(sonSelectionOutilURL!, &sonSelectionOutil)
        let sonSelectionURL = NSBundle.mainBundle().URLForResource("Selection", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(sonSelectionURL!, &sonSelection)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
}
