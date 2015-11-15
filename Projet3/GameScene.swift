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
    
    var labelBilleGratuite:SKLabelNode?
    var textBilleGratuite:UITextField?
    var labelDiff:SKLabelNode?
    var textDiff:UITextField?
    
    //Variables globale à la classe
    var ptsBilleGratuite = 1000
    var coteDifficulte = 2
    var nomObjet = "Spaceship"
    var viewController: UIViewController? //Identifie le menuPrincipal
    var table = SKNode()
    var menuGauche = SKNode()
    var menuDroit = SKNode()
    var nodesSelected = [Objet]()
    var savedSelected = [Objet]()
    var selection = false
    var construireMur = false
    let chemin = CGPathCreateMutable()
    var murTemp = SKNode()
    var deplacement = false
    var nodeTouchee = Objet()
    var endroitPrecedent = CGPoint()
    var menuGaucheOuvert = true
    var menuDroitOuvert = true
    var murPosInitiale: CGPoint?
    var menuTouchee = SKNode()
    var leftSwipe = UISwipeGestureRecognizer()
    var rightSwipe = UISwipeGestureRecognizer()
    
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
        
        //Mes gestures de swype pour les barres latérales
        leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        
        //On initialise la table et les menus pour une utilisation facile par la suite
        table = self.childNodeWithName("table")!
        menuGauche = self.childNodeWithName("menuGauche")!
        menuDroit = self.childNodeWithName("menuDroit")!
        
        //Initialise les labels et les text fields des propriétés
        initLabels()
        
        updateVisibiliteCorbeille()
        
    }
    
    ///Fonctopn qui gère les swypes gestures
    ///-On l'utilise pour montrer ou cacher les barres latérales
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        //Un swype vers la gauche
        if (sender.direction == .Left) {
            if menuTouchee == menuGauche && menuGaucheOuvert {
                toggleMenus(menuTouchee)
            }else if menuTouchee == menuDroit && !menuDroitOuvert {
                toggleMenus(menuTouchee)
            }
        }
        //Un swype vers la droite
        if (sender.direction == .Right) {
            if menuTouchee == menuGauche && !menuGaucheOuvert {
                toggleMenus(menuTouchee)
            }else if menuTouchee == menuDroit && menuDroitOuvert {
                toggleMenus(menuTouchee)
            }
        }
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
        
        //On enregistre la position initiale du mur
        murPosInitiale = touches.first!.locationInNode(self)
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            
            //On désactive les swipes dans l'écran si c'est pas un menu,
            //Sinon on ne peut plus déplacer un objet sans être arrêté par le gesture
            if let nom = touchedNode.name {
                if nom.substringToIndex(nom.startIndex.advancedBy(4))  == "menu" {
                    menuTouchee = touchedNode
                }else{
                    swipePossible(false)
                }
            }
            
            //On enregistre l'endroit précédent pour le déplacement des objets
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
                        feuFeuJolieFeu(node)
                    }
                }
                deplacement = true
                endroitPrecedent = location
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        swipePossible(true)
        
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
                    
                    if construireMur && !deplacement && name == "table" {
                        let touch = touches.first
                        let position2 = touch!.locationInNode(self)
                        
                        if table.containsPoint(murPosInitiale!) && table.containsPoint(position2) {
                            let longeurMur = murPosInitiale?.distance(position2)
                            let angleMur = murPosInitiale?.angle(position2)
                            
                            creerObjet(murPosInitiale!.centre(position2), typeObjet: "mur", longeurMur: longeurMur, angleMur: angleMur)
                        }
                    }
                    
                    switch name {
                    case "boutonmenu":
                        quitterModeEdition()
                    case "boutonmur":
                        construireMur = true
                        AudioServicesPlaySystemSound(sonSelectionOutil)
                    default: break
                    }
                    if !surTable(location, node: touchedNode)
                    {
                        if selection
                        {
                            switch name {
                            case "boutonsave_select":
                                savedSelected = nodesSelected
                            case "boutonDuplication":
                                dupplication()
                            case "boutonsame_select":
                                sameSelect()
                            case "boutonDelete":
                                effacerNoeuds()
                            default:
                                deselectionnerTout()
                                break
                            }
                            
                            //TODO: Vérifier si nécéssaire
                            cliqueSurBoutonObj(name)
                        }else
                        {
                            //C'est ici que les nouveaux objets sont créés
                            if !cliqueSurBoutonObj(name) && name == "table" && nomObjet != "Spaceship" && !construireMur
                            {
                                //let endroitSurTable = table.convertPoint(location, fromNode: self)
                                creerObjet(location,typeObjet: nomObjet)
                                
                                AudioServicesPlaySystemSound(sonObjSurTable);
                            }else if name == "boutonload_select"
                            {
                                loadSelect()
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
    
    func quitterModeEdition(){
        var vc: UIViewController = UIViewController()
        vc = self.view!.window!.rootViewController!
        self.viewController?.performSegueWithIdentifier("backToMenu", sender: vc)
    }
    
    func swipePossible(valeur: Bool){
        leftSwipe.enabled = valeur
        rightSwipe.enabled = valeur
    }
    
    ///Fonction qui resélectionne les noeurs de la sélection enregistrés (qui charge la sélection)
    ///-Actionné par le bouton loadSelect
    func loadSelect(){
        nodesSelected = savedSelected
        if nodesSelected.count > 0
        {
            for node in nodesSelected
            {
                selectNode(node)
            }
        }
    }
    
    ///Fonction qui efface les noeuds qui sont sélectionné
    ///-Actionné par le bouton delete
    func effacerNoeuds(){
        //Si on delete des nodes qui sont dans la sélection sauvegardé, on ne doit pas les resélectionné lors du chargement de la séleciton (ils n'existent plus).
        for node in nodesSelected
        {
            savedSelected = savedSelected.filter {$0 != node}
            animationExplosion(node)
            node.removeFromParent()
        }
        
        //On efface la sélection, donc plus rien n'est sélectionné
        selection = false
        updateVisibiliteCorbeille()
        
        // jouer un son
        AudioServicesPlaySystemSound(sonCorbeille);
    }
    
    ///Cette fonction permet de désélectionner tous les noeuds sélectionnés
    func deselectionnerTout(){
        selection = false
        for node in nodesSelected
        {
            unselectNode(node)
        }
    }
    
    ///Fonction qui vérifie si le noeud est sur la table ou non
    func surTable(location: CGPoint, node: SKNode) -> Bool
    {
        if let noeud = node as? Objet {
            let largeur = noeud.size.width / 2
            let hauteur = noeud.size.height / 2
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
            }
        }
        return false
    }
    
    ///Fonction qui dupplique les objets sélectionnés
    ///-Actionné par le bouton dupplication
    func dupplication(){
        // var newNode = NewNode()
        for node in nodesSelected
        {
            unselectNode(node)
            let nodeCopie = node.copier()
            self.addChild(nodeCopie)
            selectNode(nodeCopie)
        }
    }
    
    ///Fonction qui sélectionne tous les objets du même type
    ///-Actionné par le bouton sameSelect
    func sameSelect(){
        //On vérifie sur les enfants de la scène
        if nodesSelected.count == 1 {
            for enfant in self.children
            {
                //On retrouve le nom du node sélectionné
                if enfant.name == nodesSelected[0].name
                {
                    if let monEnfant = enfant as? Objet
                    {
                        selectNode(monEnfant)
                    }
                }
            }
        }
    }
    
    /**
     Cette méthode permet de créer un objet sur la table de jeu.
     
     Entrée:
     - endroitSurTable: Endoit où l'objet sera créé, en coordonnée de la table
     
     Note importante:
     - Cette méthode utilise la variable de classe "nomObjet" pour fabriquer le bon objet
     */
    func creerObjet(endroitSurTable: CGPoint, typeObjet: String, longeurMur: CGFloat?=nil, angleMur: CGFloat?=nil){
        let objet = Objet(imageNamed: typeObjet)
        objet.name = typeObjet
        
        //Ici je set le ratio des objets pour garder celui de la scène et non celui de la table
        //let monRatio = self.frame.height / self.frame.width
        
        objet.xScale = 0.5
        objet.yScale = 0.5 //* monRatio
        
        objet.position = endroitSurTable
        
        setPhysicsBody(objet, masque: 1) //Masque: 1 -> Objets sur la table
        
        //Indique qu'on est en train de construire un mur
        if longeurMur != nil && angleMur != nil {
            if longeurMur! < 5 {
                return
            }
            objet.size.width = longeurMur!
            objet.zRotation = angleMur!
        }
        
        self.addChild(objet.copy() as! Objet)
    }
    
    func animationExplosion(node: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "deleteNodeEffect") {
            fireParticles.position = node.position
            addChild(fireParticles)
            
            //On doit delete la mémoire relié aux particules après l'animation
            let delai = SKAction.waitForDuration(1)
            self.runAction(delai, completion: {
                fireParticles.removeFromParent()
            })
        }
    }
    
    func feuFeuJolieFeu(node: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "feu") {
            fireParticles.position = node.position
            addChild(fireParticles)
            
            //On doit delete la mémoire relié aux particules après l'animation
            let delai = SKAction.waitForDuration(1)
            self.runAction(delai, completion: {
                fireParticles.removeFromParent()
            })
            
        }
    }
    
    ///Fonction qui set un physicsbody (boite englobante et physique si nécéssaire)
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
    
    ///Fonction qui met à jour la visibilité de la corbeille
    func updateVisibiliteCorbeille(){
        if selection
        {
            menuGauche.childNodeWithName("boutonDelete")?.alpha = 1
        }else
        {
            menuGauche.childNodeWithName("boutonDelete")?.alpha = 0
        }
    }
    
    ///Fonction qui sélectionne un objet
    func selectNode(newObjectSelection: Objet?) {
        newObjectSelection!.alpha = 0.5
        nodesSelected.append(newObjectSelection!)
        selection = true
        updateVisibiliteCorbeille()
    }
    
    ///Fonction qui désélectionne un objet
    func unselectNode(objet: Objet?) {
        nodesSelected = nodesSelected.filter {$0 != objet!}
        objet!.alpha = 1
        if nodesSelected.isEmpty
        {
            selection = false
            updateVisibiliteCorbeille()
        }
    }
    
    ///Fonction qui ajuste les menus s'ils sont touchés
    func toggleMenus(touchedNode: SKNode){
        if touchedNode == menuGauche {
            if menuGaucheOuvert {
                let moveLeft = SKAction.moveByX(-200, y:0, duration:0.2)
                menuGauche.runAction(moveLeft)
                menuGaucheOuvert = false
            }else {
                let moveRight = SKAction.moveByX(200, y:0, duration:0.2)
                menuGauche.runAction(moveRight)
                menuGaucheOuvert = true
            }
            return
        }
        
        if touchedNode == menuDroit {
            if menuDroitOuvert {
                let moveRight = SKAction.moveByX(200, y:0, duration:0.2)
                menuDroit.runAction(moveRight)
                
                textPositionX?.hidden = true
                textPositionY?.hidden = true
                self.textRotation?.hidden = true
                self.textScale?.hidden = true
                self.textPoints?.hidden = true
                self.textBilleGratuite?.hidden = true
                self.textDiff?.hidden = true
                
                menuDroitOuvert = false
            }else {
                let moveLeft = SKAction.moveByX(-200, y:0, duration:0.2)
                menuDroit.runAction(moveLeft, completion: {
                    self.textPositionX?.hidden = false;
                    self.textPositionY?.hidden = false;
                    self.textRotation?.hidden = false;
                    self.textScale?.hidden = false;
                    self.textPoints?.hidden = false;
                    self.textBilleGratuite?.hidden = false;
                    self.textDiff?.hidden = false;
                })
                
                menuDroitOuvert = true
            }
            return
        }
    }
    
    ///Met à jour le text des zones de text
    func updateTextProprieteObjet(){
        
        textBilleGratuite!.text = String(ptsBilleGratuite)
        textDiff!.text = String(coteDifficulte)
        
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
        textBilleGratuite!.resignFirstResponder()
        textDiff!.resignFirstResponder()
        
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
        
        if(textPoints!.text! != "" && nodesSelected.count == 1){
            if nodesSelected[0].name == "cible" || nodesSelected[0].name == "butoirTriDroit" || nodesSelected[0].name == "butoirTriGauche" {
                if let s = NSNumberFormatter().numberFromString(textPoints!.text!) {
                    let sInt = Int(s)
                    nodesSelected[0].points = sInt
                }
            }
            
        }
        
        if(textBilleGratuite!.text! != ""){
            if let s = NSNumberFormatter().numberFromString(textBilleGratuite!.text!) {
                let sInt = Int(s)
                ptsBilleGratuite = sInt
            }
        }
        
        if(textDiff!.text! != ""){
            if let s = NSNumberFormatter().numberFromString(textDiff!.text!) {
                let sInt = Int(s)
                coteDifficulte = sInt
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
    
    ///Fonction qui initialise les labels et text fields pour les propriétés
    func initLabels(){
        
        
        textPositionX = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMidY(self.frame)-200, width: 50, height: 20))
        self.view!.addSubview(textPositionX!)
        textPositionX!.backgroundColor = UIColor.grayColor()
        textPositionX!.delegate = self
        
        textPositionY = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMidY(self.frame)-200, width: 50, height: 20))
        self.view!.addSubview(textPositionY!)
        textPositionY!.backgroundColor = UIColor.grayColor()
        textPositionY!.delegate = self
        
        textRotation = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMidY(self.frame)-120, width: 50, height: 20))
        self.view!.addSubview(textRotation!)
        textRotation!.backgroundColor = UIColor.grayColor()
        textRotation!.delegate = self
        
        textScale = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMidY(self.frame)-160, width: 50, height: 20))
        self.view!.addSubview(textScale!)
        textScale!.backgroundColor = UIColor.grayColor()
        textScale!.delegate = self
        
        textPoints = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMidY(self.frame)-80, width: 50, height: 20))
        self.view!.addSubview(textPoints!)
        textPoints!.backgroundColor = UIColor.grayColor()
        textPoints!.delegate = self
        
        textBilleGratuite = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMidY(self.frame)-0, width: 50, height: 20))
        self.view!.addSubview(textBilleGratuite!)
        textBilleGratuite!.backgroundColor = UIColor.whiteColor()
        textBilleGratuite!.delegate = self
        
        textDiff = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMidY(self.frame)+40, width: 50, height: 20))
        self.view!.addSubview(textDiff!)
        textDiff!.backgroundColor = UIColor.whiteColor()
        textDiff!.delegate = self
        
        updateTextProprieteObjet()
    }
}
