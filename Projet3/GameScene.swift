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
    var ptsPasserNiveau = 2000
    var coteDifficulte = 2
    var ptsButoirCirc = 5
    var ptsButoirTri = 5
    var ptsCible = 5
    
    var nomObjet = "Spaceship"
    var viewController: UIViewController? //Identifie le menuPrincipal
    var table = SKNode()
    var menuGauche = SKNode()
    var menuDroit = SKNode()
    var nodesSelected = [SKSpriteNode]()
    var savedSelected = [SKSpriteNode]()
    var nodesSurTable = [monObjet]()
    var construireMur = false
    var murTemp = SKNode()
    var deplacement = false
    var nodeTouchee = SKSpriteNode()
    var endroitPrecedent = CGPoint()
    var menuGaucheOuvert = true
    var menuDroitOuvert = true
    var posInitiale: CGPoint?
    var menuTouchee = SKNode()
    var leftSwipe = UISwipeGestureRecognizer()
    var rightSwipe = UISwipeGestureRecognizer()
    var pan = false
    var marqueurSelectionBouton = SKShapeNode()
    var marqueurSelectionOutil = SKShapeNode()
    var uneFrameSurX = 0
    var centre = CGPoint() //Variable qui détient le centre de la rotation multiple
    
    //Les variables de son
    var sonCorbeille: SystemSoundID = 0
    var sonObjSurTable: SystemSoundID = 0
    var sonSelectionOutil: SystemSoundID = 0
    var sonSelection: SystemSoundID = 0
    
    //Variables pour la rotation des objets
    var offset:CGFloat = 0
    var theRotation:CGFloat = 0
    
    //Variable qui represente la carte de jeux (pour XML)
    var carte : Carte!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        ///Chargement de la scene selon la Carte xml (si on a edite une carte existante)
        if carte != nil{
            chargerCarte(carte)
        }
        
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
        
        //On set la physique de la table
        let rect = CGRect(origin:CGPoint(x:table.frame.origin.x-table.position.x, y:table.frame.origin.y-table.position.y), size:table.frame.size)
        table.physicsBody = SKPhysicsBody(edgeLoopFromRect:rect)
        
        //Initialise les labels et les text fields des propriétés
        initLabels()
        
        playBackgroundMusic("MusiqueEspace")
        
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
            /*for objetCourant in nodesSurTable {
                let pos = table.convertPoint(objetCourant.noeud.position, fromNode: self)
                objetCourant.noeud.removeFromParent()
                table.addChild(objetCourant.noeud)
                objetCourant.noeud.position = pos
                objetCourant.noeud.zPosition = -14
            }*/
        }
        if sender.state == .Changed {
            //Pendant la le pincement
            
            if nodesSelected.count > 0 {
                //TODO, on doit aussi scale la boite englobante**
                for objet in nodesSurTable {
                    if nodesSelected.contains(objet.noeud) {
                        objet.noeud.size.width = objet.noeud.size.width * sender.scale
                        objet.noeud.size.height = objet.noeud.size.height * sender.scale
                        objet.scale *= sender.scale
                        setPhysicsBody(objet.noeud, masque: 1)
                    }
                }
                sender.scale = 1
            }else{
                //Ici on scale la vue au complet (zoom)
                //TODO: Ajouter un max et un min au scale de la scène
                //table.xScale *= sender.scale
                //table.yScale *= sender.scale
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
            //Au début de la rotation, on trouve le centre (si sélection multiple)
            if nodesSelected.count > 1 {
                centre = centreDesNodesSelectionnees() //Centre des objets en sélection
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
                    let dx = node.position.x - centre.x // Get distance X from center
                    let dy = node.position.y - centre.y // Get distance Y from center
                    
                    let current_angle = atan(dy / dx) // Current angle is the arctan of dy / dx
                    
                    let next_angle = current_angle + theRotation // Sum how much you want to rotate in radians
                    
                    let rotationRadius = node.position.distance(centre)
                    
                    // the new x is: center + radius*cos(x)
                    // the new y is: center + radius*sin(y)
                    // if dx < 0 you need to get the oposite value of the position
                    let new_x = dx >= 0 ? centre.x + rotationRadius * cos(next_angle) : centre.x - rotationRadius * cos(next_angle)
                    let new_y = dx >= 0 ? centre.y + rotationRadius * sin(next_angle) : centre.y - rotationRadius * sin(next_angle)
                    
                    let new_point = CGPoint(x: new_x, y: new_y)
                    
                    let action = SKAction.moveTo(new_point, duration: 0.2)
                    
                    node.runAction(action)
                }
            }
        }
        if sender.state == .Ended {
            //Après la rotation
            if nodesSelected.count == 1 {
                self.offset = theRotation * -1
                
                for node in nodesSelected
                {
                    node.zRotation = theRotation
                }
            }
            updateTextProprieteObjet()
            
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Si on touche avec plusieurs doit, c'est surement un gesture, on ne fait rien
        if (touches.count > 1) {
            return
        }
        
        //On enregistre la position initiale (pour le mur et déplacements table)
        posInitiale = touches.first!.locationInNode(self)
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            
            //On désactive les swipes dans l'écran si c'est pas un menu,
            //Sinon on ne peut plus déplacer un objet sans être arrêté par le gesture
            if let nom = touchedNode.name {
                if nom.containsString("menu") {
                    menuTouchee = touchedNode
                }else{
                    swipePossible(false) //On bloque les swipes pendant le déplacement
                }
            }
            
            //On enregistre l'endroit précédent pour le déplacement des objets
            endroitPrecedent = location
            if table.containsPoint(touchedNode.position)
            {
                //On cast le SKNode en SKPriteNode
                if let monNode = touchedNode as? SKSpriteNode
                {
                    nodeTouchee = monNode
                }
            }
            
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Si on touche avec plusieurs doit, c'est surement un gesture, on ne fait rien
        if (touches.count > 1) {
            return
        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            //TODO: Utilisez la bounding box a la place.
            //TODO: Régler le bug qui fait que quand je fais un gesture, ça déplace les objets!!!
            if selection() && nodesSelected.contains(nodeTouchee)
            {
                for node in nodesSelected
                {
                    let nouvEndroit = CGPoint(x:(node.position.x + location.x - endroitPrecedent.x),y:(node.position.y + location.y - endroitPrecedent.y))
                    //TODO: On doit utiliser soit la boite englobante ou soit les bordures des sprites
                    if surTable(nouvEndroit, node: node)
                    {
                        node.position = nouvEndroit
                        if uneFrameSurX == 0 {
                            feuFeuJolieFeu(node)
                        }
                    }
                }
                miseAJourFrameAnimationFeu()
                deplacement = true
                endroitPrecedent = location
            }else if !construireMur && nodeAtPoint(location) == table && nodeTouchee == table && pan {
                for node in self.children {
                    if let noeud = node as? SKSpriteNode {
                        if noeud.name!.containsString("objet") {
                            let offSetPosition = CGPoint(x: location.x - posInitiale!.x,y:location.y - posInitiale!.y)
                            noeud.position.x += offSetPosition.x
                            noeud.position.y += offSetPosition.y
                        }
                    }
                }
                let offSetPosition = CGPoint(x: location.x - posInitiale!.x,y:location.y - posInitiale!.y)
                table.position.x += offSetPosition.x
                table.position.y += offSetPosition.y
                posInitiale = location
                deplacement = true
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

        swipePossible(true) //On débloque les swipes après avoir terminé le déplacement
        nodeTouchee = SKSpriteNode() //On réinitialise l'objet touché dans touchesBegin
        
        //Si on touche avec plusieurs doit, c'est surement un gesture, on ne fait rien
        if (touches.count > 1) {
            return
        }
        
        if deplacement
        {
            deplacement = false
        }else
        {
            for touch in (touches ) {
                let location = touch.locationInNode(self)
                if let touchedNode = self.nodeAtPoint(location) as? SKSpriteNode {
                    
                    if let name = touchedNode.name
                    {
                        if name == "outilPan" {
                            pan = !pan
                            if pan {
                                selectionnerOutil("outilPan")
                            }else{
                                deselectionnerOutil("outilPan")
                            }
                        }
                        
                        if construireMur && name == "table" {
                            let touch = touches.first
                            let position2 = touch!.locationInNode(self)
                            creerMur(position2)
                        }
                        
                        switch name {
                        case "outilmenu":
                            quitterModeEdition()
                            
                            ///sauvegarde de carte sous format xml
                        case "outilSauvegarde":
                            //enrregistrement de la nouvelle carte
                            if carte == nil{
                                sauvegarderNouvelleCarte()
                            }
                            else{ //enregistrement d'une carte existante
                                //sauvegarderCarteActuelle()
                                sauvegarderNouvelleCarte()
                            }

                        case "boutonmur":
                            construireMur = true
                            AudioServicesPlaySystemSound(sonSelectionOutil)
                        default: break
                        }
                        if !touchedNode.name!.containsString("objet")
                        {
                            if selection()
                            {
                                switch name {
                                case "outilsave_select":
                                    savedSelected = nodesSelected
                                case "outilDuplication":
                                    dupplication()
                                    flashSelectionOutil("outilDuplication")
                                case "outilsame_select":
                                    sameSelect()
                                case "outilDelete":
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
                                }else if name == "outilload_select"
                                {
                                    loadSelect()
                                }
                            }
                        }else
                        {
                            cliqueObjet(touchedNode, location: location)
                        }
                    }
                }
            }
        }
        updateTextProprieteObjet()
    }
    
    func quitterModeEdition(){
        Popups.SharedInstance.ShowAlert(self.viewController!,
            title: "Quitter",
            message: "Êtes-vous certains de vouloir quitter? Assurez-vous d'avoir sauvegardé vos changements.",
            buttons: ["Quitter" , "Annuler"]) { (buttonPressed) -> Void in
                if buttonPressed == "Quitter" {
                    backgroundMusicPlayer.stop()
                    var vc: UIViewController = UIViewController()
                    vc = self.view!.window!.rootViewController!
                    self.viewController?.performSegueWithIdentifier("backToMenu", sender: vc)
                } else if buttonPressed == "Annuler" {
                    //On fait rien sinon
                }
        }
    }
    
    func creerMur(position2: CGPoint){
        if table.containsPoint(posInitiale!) && table.containsPoint(position2) {
            let longeurMur = posInitiale?.distance(position2)
            let angleMur = posInitiale?.angle(position2)
            
            creerObjet(posInitiale!.centre(position2), typeObjet: "mur", longeurMur: longeurMur, angleMur: angleMur)
        }
    }
    
    func miseAJourFrameAnimationFeu(){
        ++uneFrameSurX
        if uneFrameSurX >= nodesSelected.count / 2 {
            uneFrameSurX = 0
        }
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
        for objetCourant in nodesSurTable
        {
            let monNoeud = objetCourant.noeud
            if nodesSelected.contains(monNoeud) {
                savedSelected = savedSelected.filter {$0 != monNoeud}
                nodesSurTable = nodesSurTable.filter {$0.noeud != monNoeud}
                unselectNode(monNoeud)
                animationExplosion(monNoeud)
                monNoeud.removeFromParent()
            }
        }
        
        updateVisibiliteCorbeille()
        
        //On update les zone de texte des propriétés de l'objet
        updateTextProprieteObjet()
        
        // jouer un son
        AudioServicesPlaySystemSound(sonCorbeille);
    }
    
    ///Cette fonction permet de désélectionner tous les noeuds sélectionnés
    func deselectionnerTout(){
        for node in nodesSelected
        {
            unselectNode(node)
        }
    }
    
    ///Fonction qui vérifie si le noeud est sur la table ou non
    func surTable(location: CGPoint, node: SKNode) -> Bool
    {
        if let noeud = node as? SKSpriteNode {
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
    
    ///Fonction qui retourne vrai si un objet est sélectionné
    func selection() -> Bool{
        if nodesSelected.count > 0 {
            return true
        }else{
            return false
        }
    }
    
    ///Fonction qui dupplique les objets sélectionnés
    ///-Actionné par le bouton dupplication
    func dupplication(){
        
        for objetCourant in nodesSurTable {
            let node = objetCourant.noeud
            if nodesSelected.contains(node) {
                unselectNode(node)
                let nodeCopie = node.copy() as! SKSpriteNode
                setPhysicsBody(nodeCopie, masque: 1) //Masque: 1 -> Objets sur la table
                let nouvObjet = monObjet(noeud: nodeCopie, points: objetCourant.points)
                nodesSurTable.append(nouvObjet)
                self.addChild(nodeCopie)
                selectNode(nodeCopie)
            }
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
                if enfant.name == nodesSelected[0].name && enfant != nodesSelected[0]
                {
                    if let monEnfant = enfant as? SKSpriteNode
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
        let objet = SKSpriteNode(imageNamed: typeObjet)
        objet.name = "objet" + typeObjet
        
        //Ici je set le ratio des objets pour garder celui de la scène et non celui de la table
        //let monRatio = self.frame.height / self.frame.width
        
        objet.size.width *= 0.5
        objet.size.height *= 0.5 //* monRatio
        
        objet.position = endroitSurTable

        objet.zPosition = -14
        
        //Pour la construction d'un mur
        if longeurMur != nil && angleMur != nil {
            if longeurMur! < 5 {
                return
            }
            objet.size.width = longeurMur!
            objet.zRotation = angleMur!
        }
        
        setPhysicsBody(objet, masque: 1) //Masque: 1 -> Objets sur la table
        
        self.addChild(objet)
        
        let temp = monObjet(noeud: objet)
        nodesSurTable.append(temp)
        
        AudioServicesPlaySystemSound(sonObjSurTable);
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
    func setPhysicsBody(objet: SKSpriteNode, masque: UInt32){
        objet.physicsBody = SKPhysicsBody.init(texture: objet.texture!, size: objet.size)
        
        objet.physicsBody?.affectedByGravity = false
        objet.physicsBody?.allowsRotation = false
        
        //Catégorie (masque) pour les collisions
        objet.physicsBody?.categoryBitMask = masque
    }
    
    ///Appelé lorsqu'on clique sur un objet de type "bouton"
    func cliqueSurBoutonObj(name: String) -> Bool{
        if name.containsString("bouton") {
            selectionnerBouton(name)
            if name != "boutonmur" {
                construireMur = false
            }
            nomObjet = name.substringFromIndex(name.startIndex.advancedBy(6))
            // jouer un son
            AudioServicesPlaySystemSound(sonSelectionOutil);
            return true
        }
        return false
    }
    
    func selectionnerBouton(name: String){
        marqueurSelectionBouton.removeFromParent()
        let noeud = menuGauche.childNodeWithName(name)
        marqueurSelectionBouton = SKShapeNode(rect: (noeud?.frame)!)
        marqueurSelectionOutil.zPosition = -4
        menuGauche.addChild(marqueurSelectionBouton)
    }
    
    func selectionnerOutil(name: String){
        marqueurSelectionOutil.removeFromParent()
        let noeud = menuGauche.childNodeWithName(name)
        marqueurSelectionOutil = SKShapeNode(rect: (noeud?.frame)!)
        marqueurSelectionOutil.zPosition = -4
        menuGauche.addChild(marqueurSelectionOutil)
    }
    
    func deselectionnerOutil(name: String){
        marqueurSelectionOutil.removeFromParent()
    }
    
    func flashSelectionOutil(name: String){
        selectionnerOutil(name)
        let delai = SKAction.waitForDuration(0.1)
        self.runAction(delai, completion: {
            self.deselectionnerOutil(name)
        })
    }
    
    ///On sélectionne ou désélectionne l'objet qu'on reçoit en parametre
    func cliqueObjet(touchedNode: SKNode, location: CGPoint){
        //let noeud = self.physicsWorld.bodyAtPoint(location)
        
        if let objSelectionne = touchedNode as? SKSpriteNode
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
        if selection()
        {
            menuGauche.childNodeWithName("outilDelete")?.alpha = 1
        }else
        {
            menuGauche.childNodeWithName("outilDelete")?.alpha = 0
        }
    }
    
    ////Méthode qui retourne le CGPoint du centre des objets sélectionnés
    func centreDesNodesSelectionnees() -> CGPoint{
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
            if node.position.y < minY{
                minY = node.position.y
            }
        }
        
        return CGPoint(x: (((maxX-minX)/2)+minX), y: (((maxY-minY)/2)+minY))
    }
    
    ///Fonction qui sélectionne un objet
    func selectNode(newObjectSelection: SKSpriteNode?) {
        newObjectSelection!.alpha = 0.5
        nodesSelected.append(newObjectSelection!)
        updateVisibiliteCorbeille()
    }
    
    ///Fonction qui désélectionne un objet
    func unselectNode(objet: SKSpriteNode?) {
        nodesSelected = nodesSelected.filter {$0 != objet!}
        objet!.alpha = 1
        if nodesSelected.isEmpty
        {
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
            textRotation!.text = NSString(format: "%.01f", nodesSelected[0].zRotation.RadianEnDegree) as String
            for objet in nodesSurTable {
                if objet.noeud == nodesSelected[0] {
                    textScale!.text = NSString(format: "%.01f", objet.scale) as String
                }
            }
            
            
            if nodesSelected[0].name == "objetcible" || nodesSelected[0].name == "objetbutoirTriDroit" || nodesSelected[0].name == "objetbutoirTriGauche" || nodesSelected[0].name == "objetbutoirCirc" {
                
                for monNoeud in nodesSurTable {
                    if monNoeud.noeud == nodesSelected[0] {
                        switch nodesSelected[0].name! {
                        case "objetcible":
                            textPoints!.text = String(self.ptsCible)
                            break
                        case "objetbutoirTriDroit":
                            textPoints!.text = String(self.ptsButoirTri)
                            break
                        case "objetbutoirTriGauche":
                            textPoints!.text = String(self.ptsButoirTri)
                            break
                        case "objetbutoirCirc":
                            textPoints!.text = String(self.ptsButoirCirc)
                            break
                        default: break
                        }
                    }
                }
                
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
        
        let converter = NSNumberFormatter()
        converter.decimalSeparator = "."
        
        if(textPositionX!.text! != "" && textPositionY!.text! != "" && nodesSelected.count == 1){
            if let x = converter.numberFromString(textPositionX!.text!) {
                if let y = converter.numberFromString(textPositionY!.text!){
                    let xFloat = CGFloat(x)
                    let yFloat = CGFloat(y)
                    let point = CGPoint(x: xFloat, y: yFloat)
                    if table.containsPoint(point) {
                        nodesSelected[0].position = point
                    }else{
                        textPositionX!.text! = nodesSelected[0].position.x.description
                        textPositionY!.text! = nodesSelected[0].position.y.description
                    }
                }else{
                    updateTextProprieteObjet()
                }
            }else{
                updateTextProprieteObjet()
            }
        }
        
        if(textRotation!.text! != "" && nodesSelected.count == 1){
            if let z = converter.numberFromString(textRotation!.text!) {
                let zFloat = CGFloat(z)
                nodesSelected[0].zRotation = zFloat.degreeEnRadian
            }else{
                updateTextProprieteObjet()
            }
        }
        
        if(textScale!.text! != "" && nodesSelected.count == 1){
            if let s = converter.numberFromString(textScale!.text!) {
                let sFloat = CGFloat(s)
                
                for objet in nodesSurTable {
                    if objet.noeud == nodesSelected[0] {
                        if objet.scale != 0 && sFloat >= 0.2 {
                            //objet.noeud.size.height /= objet.scale
                            //objet.noeud.size.width /= objet.scale
                            objet.noeud.size.height = (objet.noeud.size.height / objet.scale) * sFloat
                            objet.noeud.size.width = (objet.noeud.size.width / objet.scale) * sFloat
                            
                            objet.scale = sFloat
                            setPhysicsBody(objet.noeud, masque: 1)
                        }
                    }
                }
            }else{
                updateTextProprieteObjet()
            }
        }
        
        if(textPoints!.text! != "" && nodesSelected.count == 1){
            if nodesSelected[0].name == "objetcible" || nodesSelected[0].name == "objetbutoirTriDroit" || nodesSelected[0].name == "objetbutoirTriGauche" || nodesSelected[0].name == "objetbutoirCirc" {
                if let s = converter.numberFromString(textPoints!.text!) {
                    let sInt = Int(s)
                    
                    for monNoeud in nodesSurTable {
                        if monNoeud.noeud == nodesSelected[0] {
                            switch nodesSelected[0].name! {
                            case "objetcible":
                                self.ptsCible = sInt
                                break
                            case "objetbutoirTriDroit":
                                self.ptsButoirTri = sInt
                                break
                            case "objetbutoirTriGauche":
                                self.ptsButoirTri = sInt
                                break
                            case "objetbutoirCirc":
                                self.ptsButoirCirc = sInt
                                break
                            default: break
                            }
                        }
                    }
                }else{
                    updateTextProprieteObjet()
                }
            }
            
        }
        
        if(textBilleGratuite!.text! != ""){
            if let s = converter.numberFromString(textBilleGratuite!.text!) {
                let sInt = Int(s)
                ptsBilleGratuite = sInt
            }else{
                updateTextProprieteObjet()
            }
        }
        
        if(textDiff!.text! != ""){
            if let s = converter.numberFromString(textDiff!.text!) {
                let sInt = Int(s)
                coteDifficulte = sInt
            }else{
                updateTextProprieteObjet()
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
    
    ///Construit la scene selon l'objet Carte.
    ///Ceci inclus les objets et les configurations
    func chargerCarte(carte : Carte){
        ///TODO:
        ///afficer le nom de la carte en hau du mode editeur
        
        ///charger les configurations de la carte
        chargerProprietesXML(carte)
        
        ///cree les objets de l'arbre (on a besoin de )
        chargerObjetsXML(carte)
        
        
    }
    
    ///Charge les proprietes de "carte" sur la scene actuelle
    func chargerProprietesXML(carte : Carte){
        ptsBilleGratuite = carte.proprietes.pointagePourBillegratuite!
        coteDifficulte = carte.proprietes.niveauDiffulte!
        ptsButoirCirc =  carte.proprietes.pointageButoirCirculaire!
        ptsButoirTri = carte.proprietes.pointageButoirTriangulaire!
        ptsCible = carte.proprietes.pointageCible!
        ptsPasserNiveau = carte.proprietes.pointagePourPasserNiveau!

    }
    
    ///Charge les objets de "carte" sur la scene actuelle
    func chargerObjetsXML(carte: Carte){
        
        ///Cretion des portails
        //TODO: connecter les portails enssemble : (1,2) (3,4) .. etc
        for portail in carte.arbre.portail{
            let positionXML = CGPoint(x: portail.positionX!, y: portail.positionY!)
            ///Todo: convertion vers coordones crlient leger
            creerObjet(positionXML,typeObjet: portail.type!)
            
        }
        
        ///Creation des murs
        for mur in carte.arbre.mur{
            let positionXML = CGPoint(x: mur.positionX!, y: mur.positionY!)
            ///Todo: convertion vers coordones crlient leger
            creerObjet(positionXML,typeObjet: mur.type!)
            
        }
        
        ///Creation des autres objets
        for objet in carte.arbre.autresObjets{
            let positionXML = CGPoint(x: objet.positionX!, y: objet.positionY!)
            
           // objet.scale,
            //objet.noeud.zRotation
            ///Todo: convertion vers coordones crlient leger
            let typeObjetXML = objet.type!
            creerObjet(table.convertPoint(positionXML, toNode: table),typeObjet: typeObjetXML)
            
            
        }
        
    }
    
    ///Cree un objet de type Carte et la sauvegarde sous format xml
    func sauvegarderNouvelleCarte(){
        
        Popups.SharedInstance.ShowAlert(self.viewController!,
            title: "Sauvegarder Carte",
            message: "Sauvegarde d'une nouvelle carte. Choisissez un nom pour votre carte.",
            buttons: ["Sauvegarder" , "Annuler"]) { (buttonPressed) -> Void in
                if buttonPressed == "Sauvegarder" {
                    
                    let nomNouvelleSauvegarde = "nouvelleCarte3.xml"
                    self.carte = Carte(nom: nomNouvelleSauvegarde)
                    
                    self.preparerCarteXML(self.carte)
                    
                    let parseur = ParseurXML()
                    
                    ///si le fichier n'existe pas deja
                    if !self.fichierExiste(nomNouvelleSauvegarde,listeDeURL: parseur.fichiersSauvegardeURLs){
                        
                        if let xmlString = self.carte.toXmlString(){
                            parseur.sauvegarderStringXML(xmlString, nomFichier: nomNouvelleSauvegarde)
                        }
                    }
                        //utilisez un autre nom de fichier pour sauvegarder
                    else{
                        print("utilisez un autre nom de fichier pour sauvegarder")
                    }
                    
                    
                } else if buttonPressed == "Annuler" {
                    //On fait rien sinon
                }
        }
    }
    
    ///verifie si
    func fichierExiste(fichierRecherche:String , listeDeURL : [NSURL]) -> Bool{
        for urlFichier in listeDeURL{
            let nomfichier = urlFichier.lastPathComponent!
            if nomfichier == fichierRecherche{
                return true
            }
        }
        return false
    }
    
    ///Remplis l'objet carte avec les objets et proprietes de la carte actuelle
    func preparerCarteXML(carte:Carte){
        ///enregistrer les proprietes
        carte.proprietes.setDifficulte(self.coteDifficulte)
        carte.proprietes.setPointageButoirCirculaire(self.ptsButoirCirc)
        carte.proprietes.setPointageButoirTriangulaire(self.ptsButoirTri)
        carte.proprietes.setPointagePourBillegratuite(self.ptsBilleGratuite)
        carte.proprietes.setPointageCible(self.ptsCible)
        carte.proprietes.setPointagePourPasserNiveau(self.ptsPasserNiveau)
        
        ///Ajouter une table
        carte.arbre.ajouterTable(0, posY: 0)
        
        ///enregistrer les objets de la scene
        for objet in nodesSurTable{
            let nom = objet.noeud.name!
            switch  nom {
            case "objetmur":
                //carte.arbre.ajouterMur(objet.noeud.position.x, posY: objet.noeud.position.y, largeurMur: ??, angleRotation: ??)
                print("TODO objetMur")
            case "objetportail":
                //carte.arbre.ajouterPortail(Int(objet.noeud.position.x), posY: Int(objet.noeud.position.y),
                //    Portail: 0/*objet.noeud.scale??*/, angleRotation: 0)
                print("TODO portail")
            default:
                let nomObjet = nom.substringFromIndex(nom.startIndex.advancedBy(5))
                
                //Traduire le nom de l'objet
                let nomObjetXml = carte.dictionnaireObjetsLegerToXml[nomObjet]
                
                carte.arbre.ajouterAutreObjet(nomObjetXml!, posX: Int(objet.noeud.position.x), posY: Int(objet.noeud.position.y), echelleObjet: Float(objet.scale), angleRotation: Float(objet.noeud.zRotation))
            }
        }
    }
    
    ///Sauvegarde la carte acutelle en écrasant la carte sur le disque
    func sauvegarderCarteActuelle(){
        //supprimer la sauvegare anterieur
        //faire une nouvelle sauvegarde
        
    }
}
