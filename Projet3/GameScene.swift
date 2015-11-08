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
    //Variables pour les labels et text fields
    var labelPosition:SKLabelNode?
    var textPositionX:UITextField?
    var textPositionY:UITextField?
    var labelRotation:SKLabelNode?
    var textRotation:UITextField?
    var labelScale:SKLabelNode?
    var textScale:UITextField?
    
    var labelPoints:SKLabelNode?
    var textPoints:UITextField?
    
    //Variables globale à la classe
    var nomObjet = "Spaceship"
    var viewController: UIViewController? //Identifie le menuPrincipal
    var table = SKNode()
    var nodesSelected = [Objet]()
    var savedSelected = [Objet]()
    var selection = false
    var construireMur = false
    let chemin = CGPathCreateMutable()
    var murTemp = SKNode()
    var deplacement = false
    var nodeTouchee = Objet()
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
    let listeDesBoutonsDeCreation = [
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
        "boutontrou"]
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
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
        
        //Initialise les labels et les text fields des propriétés
        initLabels()
        
        
    }
    
    func tailleDeLObjet(sender: UIPinchGestureRecognizer){
        if (sender.state == .Began){
            //On fait ici ce qu'on veut qui se passe quand le pincement débute
        }
        if sender.state == .Changed {
            //Pendant la le pincement
            
            if nodesSelected.count > 0 {
                //TODO, on doit aussi scale la boite englobante**
                for node in nodesSelected{
                    node.size.width = node.size.width * sender.scale
                    node.size.height = node.size.height * sender.scale
                    setPhysicsBody(node, masque: 1)
                }
                sender.scale = 1
            }else{
                //Ici on scale la vue au complet (zoom)
                //TODO: Ajouter un max et un min au scale de la scène
                self.view!.transform = CGAffineTransformScale( self.view!.transform, sender.scale, sender.scale)
                sender.scale = 1
            }
        }
        if sender.state == .Ended {
            //Après le pincement
            updateTextProprieteObjet()
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
            updateTextProprieteObjet()
            
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
                    if let monNode = touchedNode as? Objet
                    {
                        nodeTouchee = monNode
                    }
                }
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            //TODO: Utilisez la bounding box a la place.
            //TODO: Régler le bug qui fait que quand je fais un gesture, ça déplace les objets!!!
            if selection && nodesSelected.contains(nodeTouchee)
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
            nodeTouchee = Objet()
        }else
        {
            for touch in (touches ) {
                let location = touch.locationInNode(self)
                let touchedNode = self.nodeAtPoint(location)
                
                if let name = touchedNode.name
                {
                    //quand le bouton Menu est pese, on retourne au menu principal
                    if name == "boutonmenu" {
                        var vc: UIViewController = UIViewController()
                        vc = self.view!.window!.rootViewController!
                        self.viewController?.performSegueWithIdentifier("backToMenu", sender: vc)
                    }
                    
                    
                    
                    if name == "boutonmur" {
                        construireMur = true
                        // jouer un son
                        AudioServicesPlaySystemSound(sonSelectionOutil);
                    }
                    if !surTable(location, node: (touchedNode as? Objet)!)
                    {
                        if selection
                        {
                            if name == "boutonsave_select"
                            {
                                savedSelected = nodesSelected
                            }
                            
                            //Outils dublication
                            if name == "boutonDuplication"
                            {
                               // var newNode = NewNode()
                                for node in nodesSelected
                                {
                                    unselectNode(node)
                                    let nodeCopie = node.copier()
                                    self.addChild(nodeCopie)
                                    selectNode(nodeCopie)
                                    
                                    
                                    
                                }
                            }
                            if name == "boutonsame_select" && nodesSelected.count == 1
                            {
                                //On vérifie sur les enfants de la scène
                                for enfant in self.children
                                {
                                    //On retrouve le nom du node sélectionné
                                    if enfant.name == nodesSelected[0].name
                                    {
                                        if let monEnfant = enfant as? Objet
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
                            //C'est ici que les nouveaux objets sont cree
                            if !cliqueSurBoutonObj(name) && name == "table" && nomObjet != "Spaceship" && !construireMur
                            {
                                //let endroitSurTable = table.convertPoint(location, fromNode: self)
                                creerObjet(location,typeObjet: nomObjet)
                                
                                // jouer un son
                                AudioServicesPlaySystemSound(sonObjSurTable);
                            }else if name == "boutonload_select"
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
    
    func surTable(location: CGPoint, node: Objet) -> Bool
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
    
    /**
     Cette méthode permet de créer un objet sur la table de jeu.
     
     Entrée:
     - endroitSurTable: Endoit où l'objet sera créé, en coordonnée de la table
     
     Note importante:
     - Cette méthode utilise la variable de classe "nomObjet" pour fabriquer le bon objet
     */
    func creerObjet(endroitSurTable: CGPoint, typeObjet: String){
        let objet = Objet(imageNamed: typeObjet)
        objet.name = typeObjet
        
        //Ici je set le ratio des objets pour garder celui de la scène et non celui de la table
        //let monRatio = self.frame.height / self.frame.width
        
        objet.xScale = 0.5
        objet.yScale = 0.5 //* monRatio
        
        objet.position = endroitSurTable
        
        setPhysicsBody(objet, masque: 1) //Masque: 1 -> Objets sur la table
            
        self.addChild(objet.copy() as! Objet)
    }
    
    func setPhysicsBody(objet: Objet, masque: UInt32){
        objet.physicsBody = SKPhysicsBody.init(texture: objet.texture!, size: objet.size)
        
        objet.physicsBody?.affectedByGravity = false
        objet.physicsBody?.allowsRotation = false
        
        //Catégorie (masque) pour les collisions
        objet.physicsBody?.categoryBitMask = masque
    }

    ///Appelé lorsqu'on clique sur un objet de type "bouton"
    func cliqueSurBoutonObj(name: String) -> Bool{
        if listeDesBoutonsDeCreation.contains(name){
            construireMur = false
            nomObjet = name.substringFromIndex(name.startIndex.advancedBy(6))
            // jouer un son
            AudioServicesPlaySystemSound(sonSelectionOutil);
            return true
        }
        return false
    }
    
    ///On sélectionne ou désélectionne l'objet qu'on reçoit en parametre
    func cliqueAutreQueBouton(touchedNode: SKNode, location: CGPoint){
        //let noeud = self.physicsWorld.bodyAtPoint(location)
        //print(nodo?.node?.name)
        
        if let objSelectionne = touchedNode as? Objet
        {
            if nodesSelected.contains(objSelectionne)
            {
                unselectNode(objSelectionne)
            }else
            {
                selectNode(objSelectionne)
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
    
    ///Met à jour le text des zones de text
    func updateTextProprieteObjet(){
        if nodesSelected.count == 1 {
            textPositionX!.text = NSString(format: "%.0f", nodesSelected[0].position.x) as String
            textPositionY!.text = NSString(format: "%.0f", nodesSelected[0].position.y) as String
            textRotation!.text = NSString(format: "%.01f", nodesSelected[0].zRotation) as String
            textScale!.text = nodesSelected[0].xScale.description
            
            if nodesSelected[0].name == "cible" || nodesSelected[0].name == "butoirTriDroit" || nodesSelected[0].name == "butoirTriGauche" {
                textPoints!.text = String(nodesSelected[0].points)
                
                self.textPoints?.enabled = true
                textPoints!.backgroundColor = UIColor.whiteColor()
            }
            
            self.textPositionX?.enabled = true
            textPositionX!.backgroundColor = UIColor.whiteColor()
            
            self.textPositionY?.enabled = true
            textPositionY!.backgroundColor = UIColor.whiteColor()
            
            self.textScale?.enabled = true
            textScale!.backgroundColor = UIColor.whiteColor()
            
            self.textRotation?.enabled = true
            textRotation!.backgroundColor = UIColor.whiteColor()
            
            
        }else{
            textPositionX!.text = ""
            textPositionY!.text = ""
            textRotation!.text = ""
            textScale!.text = ""
            textPoints!.text = ""
            
            self.textPositionX?.enabled = false
            textPositionX!.backgroundColor = UIColor.grayColor()
            
            self.textPositionY?.enabled = false
            textPositionY!.backgroundColor = UIColor.grayColor()
            
            self.textRotation?.enabled = false
            textRotation!.backgroundColor = UIColor.grayColor()
            
            self.textScale?.enabled = false
            textScale!.backgroundColor = UIColor.grayColor()
            
            self.textPoints?.enabled = false
            textPoints!.backgroundColor = UIColor.grayColor()
        }
    }

    ///Reçoit un "enter" d'un text field (n'importe quel)
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textPositionX!.resignFirstResponder()
        textPositionY!.resignFirstResponder()
        textRotation!.resignFirstResponder()
        
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
        
        if(textRotation!.text! != "" && nodesSelected.count == 1){
            if let z = NSNumberFormatter().numberFromString(textRotation!.text!) {
                    let zFloat = CGFloat(z)
                    nodesSelected[0].zRotation = zFloat
            }
        }
        
        if(textScale!.text! != "" && nodesSelected.count == 1){
            if let s = NSNumberFormatter().numberFromString(textScale!.text!) {
                let sFloat = CGFloat(s)
                nodesSelected[0].xScale = sFloat
                nodesSelected[0].yScale = sFloat
            }
        }
        
        if(textPoints!.text! != "" && nodesSelected.count == 1 && nodesSelected[0].name == "cible" || nodesSelected[0].name == "butoirTriDroit" || nodesSelected[0].name == "butoirTriGauche"){
            if let s = NSNumberFormatter().numberFromString(textPoints!.text!) {
                let sInt = Int(s)
                nodesSelected[0].points = sInt
            }
        }
        
        return true
    }
    
    ///Initialise les sons
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
    
    ///selectionne 
    func selectNode(newObjectSelection: Objet?) {
        newObjectSelection!.alpha = 0.5
        nodesSelected.append(newObjectSelection!)
        selection = true
        updateVisibiliteCorbeille()
    }
    
    func unselectNode(objet: Objet?) {
        nodesSelected = nodesSelected.filter {$0 != objet!}
        objet!.alpha = 1
        if nodesSelected.isEmpty
        {
            selection = false
            updateVisibiliteCorbeille()
        }
    }
    
    
    ///Fonction qui initialise les labels et text fields pour les propriétés
    func initLabels(){
        //Cette partie initialise les propriétés des objets
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
        
        labelRotation = SKLabelNode(fontNamed: "Arial")
        labelRotation!.text = "Rotation (z)"
        labelRotation!.position = CGPoint(x: CGRectGetMaxX(self.frame)-205, y: CGRectGetMidY(self.frame)+105)
        labelRotation!.fontSize = 15
        self.addChild(labelRotation!)
        
        textRotation = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMidY(self.frame)-120, width: 50, height: 20))
        self.view!.addSubview(textRotation!)
        textRotation!.backgroundColor = UIColor.grayColor()
        textRotation!.delegate = self
        
        labelScale = SKLabelNode(fontNamed: "Arial")
        labelScale!.text = "Échelle"
        labelScale!.position = CGPoint(x: CGRectGetMaxX(self.frame)-218, y: CGRectGetMidY(self.frame)+145)
        labelScale!.fontSize = 15
        self.addChild(labelScale!)
        
        textScale = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMidY(self.frame)-160, width: 50, height: 20))
        self.view!.addSubview(textScale!)
        textScale!.backgroundColor = UIColor.grayColor()
        textScale!.delegate = self
        
        labelPoints = SKLabelNode(fontNamed: "Arial")
        labelPoints!.text = "Points"
        labelPoints!.position = CGPoint(x: CGRectGetMaxX(self.frame)-222, y: CGRectGetMidY(self.frame)+65)
        labelPoints!.fontSize = 15
        self.addChild(labelPoints!)
        
        textPoints = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMidY(self.frame)-80, width: 50, height: 20))
        self.view!.addSubview(textPoints!)
        textPoints!.backgroundColor = UIColor.grayColor()
        textPoints!.delegate = self
    }
}
