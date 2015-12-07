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
    var textPositionX:UITextField?
    var textPositionY:UITextField?
    var textRotation:UITextField?
    var textScale:UITextField?
    var textPointsTri:UITextField?
    var textPointsCirc:UITextField?
    var textPointsCible:UITextField?
    
    var textBilleGratuite:UITextField?
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
    var construirePortail = false
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
    var scaleTable:CGFloat = 1
    var fleche = SKNode()
    
    var tutorielEnCours = false
    var etapeTutoriel = 0
    
    //Les variables de son
    var sonCorbeille: SystemSoundID = 0
    var sonObjSurTable: SystemSoundID = 0
    var sonSelectionOutil: SystemSoundID = 0
    var sonSelection: SystemSoundID = 0
    var sonReset: SystemSoundID = 0
    
    //Variable qui represente la carte de jeux (pour XML)
    var carte : Carte!
    
    
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
        
        //On set la physique de la table
        let rect = CGRect(origin:CGPoint(x:table.frame.origin.x-table.position.x, y:table.frame.origin.y-table.position.y), size:table.frame.size)
        table.physicsBody = SKPhysicsBody(edgeLoopFromRect:rect)
        table.physicsBody!.usesPreciseCollisionDetection = true
        
        //parque c'est commme ca
        table.xScale *= 3.3
        table.yScale *= 3.3

        fleche = SKSpriteNode(imageNamed: "fleche")
        fleche.xScale = 0.5
        fleche.yScale = 0.5
        
        playBackgroundMusic("MusiqueEspace")
        
        updateVisibiliteCorbeille()
        
        ///Chargement de la scene selon la Carte xml (si on a edite une carte existante)
        if self.carte != nil{
            chargerCarte(self.carte)
        }
            //on initialize une nouvelle carte sinon
        else {

            self.carte = Carte(nom: "nouvelle_carte", date: "", time: "")
        }
        
        //Initialise les labels et les text fields des propriétés
        initLabels()
    }
    
    ///Fonctopn qui gère les swypes gestures
    ///-On l'utilise pour montrer ou cacher les barres latérales
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        detruireMurTemporaire()
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
            detruireMurTemporaire()
            //On fait ici ce qu'on veut qui se passe quand le pincement débute
        }
        if sender.state == .Changed {
            //Pendant la le pincement
            
            if nodesSelected.count > 0 {
                for objet in nodesSurTable {
                    if nodesSelected.contains(objet.noeud) {
                        let largeurInitiale = objet.noeud.xScale
                        let hauteurInitiale = objet.noeud.yScale
                        objet.noeud.xScale *= sender.scale
                        objet.noeud.yScale *= sender.scale
                        if !surTable(objet.noeud.position, node: objet.noeud) {
                            objet.noeud.xScale = largeurInitiale
                            objet.noeud.yScale = hauteurInitiale
                        }else{
                            objet.scale *= sender.scale
                        }
                    }
                }
                sender.scale = 1 //On reset le scale du sender pour pas faire exponentiel
            }else{
                //Ici on scale la vue au complet (zoom)
                
                let nouveauScale = scaleTable * sender.scale
                if nouveauScale >= 0.5 && nouveauScale <= 5 {
                    let centreDeScene = CGPoint(x: self.size.width/2, y: self.size.height/2)
                    let distanceX = centreDeScene.x - table.position.x
                    let distanceY = centreDeScene.y - table.position.y
                    let ancienScale = scaleTable
                    
                    for objet in nodesSurTable {
                        objet.positionSurTableAvantZoom = table.convertPoint(objet.noeud.position, fromNode: self)
                    }
                    
                    table.xScale *= sender.scale
                    table.yScale *= sender.scale
                    scaleTable = nouveauScale
                    
                    table.position.x = centreDeScene.x - (distanceX * (scaleTable/ancienScale))
                    table.position.y = centreDeScene.y - (distanceY * (scaleTable/ancienScale))
                    
                    for objet in nodesSurTable {
                        objet.noeud.xScale *= sender.scale
                        objet.noeud.yScale *= sender.scale
                        objet.noeud.position = self.convertPoint(objet.positionSurTableAvantZoom, fromNode: table)
                    }
                }
                
                sender.scale = 1 //On reset le scale du sender pour pas faire exponentiel
            }
            
            if tutorielEnCours && etapeTutoriel == 2 {
                //Flêche pointe l'objet sélectionné
                self.fleche.position = CGPointMake(self.nodesSurTable[self.nodesSurTable.count-1].noeud.position.x + 100, self.nodesSurTable[self.nodesSurTable.count-1].noeud.position.y)
            }
        }
        if sender.state == .Ended {
            //Après le pincement
            updateTextProprieteObjet()
        }
    }
    
    ///Cette fonction s'assure de la rotation et rotation multiple
    func rotationDeLObjet(sender: UIRotationGestureRecognizer){
        if (sender.state == .Began){
            detruireMurTemporaire()
            //Au début de la rotation, on trouve le centre (si sélection multiple)
            if nodesSelected.count > 1 {
                centre = centreDesNodesSelectionnees() //Centre des objets en sélection
            }
        }
        if sender.state == .Changed {
            if nodesSelected.count == 1 {
                nodesSelected[0].zRotation -= sender.rotation
                sender.rotation = 0
            }else if nodesSelected.count > 1 {
                for node in nodesSelected
                {
                    let dx = node.position.x - centre.x // distance en x avec le centre
                    let dy = node.position.y - centre.y // distance en y avec le centre
                    
                    let current_angle = atan(dy / dx)
                    let next_angle = current_angle - sender.rotation
                    let rotationRadius = node.position.distance(centre)
                    
                    let new_x = dx >= 0 ? centre.x + rotationRadius * cos(next_angle) : centre.x - rotationRadius * cos(next_angle)
                    let new_y = dx >= 0 ? centre.y + rotationRadius * sin(next_angle) : centre.y - rotationRadius * sin(next_angle)
                    let new_point = CGPoint(x: new_x, y: new_y)
                    
                    let tempPos = node.position
                    let tempRot = node.zRotation
                    node.position = new_point
                    node.zRotation = node.zRotation - sender.rotation
                    
                    if !surTable(node.position, node: node) {
                        node.position = tempPos
                        node.zRotation = tempRot
                    }
                    
                }
                sender.rotation = 0
            }
        }
        if sender.state == .Ended {
            //Après la rotation, on update les propriétés car la rotation a changé
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
                    if construirePortail && nodeTouchee == table && !selection() {
                        creerObjet(location, typeObjet: "portail", premierPortail: true)
                    }
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
            
            if pan {
                if (nodeAtPoint(location) == table || nodeAtPoint(location).name == "background") {
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
            }else{
                if selection() && nodesSelected.contains(nodeTouchee)
                {
                    for node in nodesSelected
                    {
                        let nouvEndroit = CGPoint(x:(node.position.x + location.x - endroitPrecedent.x),y:(node.position.y + location.y - endroitPrecedent.y))
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
                }else if construireMur && nodeAtPoint(location) == table {
                    let touch = touches.first
                    let position2 = touch!.locationInNode(self)
                    detruireMurTemporaire()
                    creerMurTemporaire(position2)
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {

        //On vérifie si un mur temporaire existe, si oui on le détruit
        detruireMurTemporaire()
        
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
                                AudioServicesPlaySystemSound(sonSelectionOutil)
                            }else{
                                deselectionnerOutil("outilPan")
                                AudioServicesPlaySystemSound(sonSelectionOutil)
                            }
                        }
                        
                        if construireMur && !pan {
                            let touch = touches.first
                            let position2 = touch!.locationInNode(self)
                            creerMur(position2)
                        }
                        
                        switch name {
                        case "outilmenu":
                            quitterModeEdition()
                        case "outilTuto":
                            modeTutoriel()
                            ///sauvegarde de carte sous format xml
                        case "outilSauvegarde":
                            self.preparerCarteXML(self.carte)
                            if carte.verifierValidite(){
                                
                                sauvegarderNouvelleCarte()
                            }else {
                                Popups.SharedInstance.ShowAlert(self.viewController!,
                                    title: "Attention! Carte invalide.",
                                    message: "Votre carte est actuellement incomplete. Pour qu'une carte sois complete celle-ci a besoin d'avoir au moin un \"ressort\", un \"generateur de billes\" et un \"trou\"",
                                    buttons: ["Ok"]){ (buttonPressed) -> Void in
                                        if buttonPressed == "Annuler" {
                                            //On fait rien sinon
                                        }
                                    }
                            }
                        case "outilReset" :
                            resetLaMap()
                        case "boutonportail":
                            construirePortail = true
                            AudioServicesPlaySystemSound(sonSelectionOutil)
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
                                    AudioServicesPlaySystemSound(sonSelectionOutil)
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
                                    if !construirePortail {
                                        creerObjet(location,typeObjet: nomObjet)
                                    }else if nodesSurTable.count > 0 {
                                            if nodesSurTable[nodesSurTable.count-1].premierPortail {
                                                creerObjet(location,typeObjet: nomObjet)
                                            }
                                    }
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
        
        if nodesSurTable.count > 0 {
            if nodesSurTable[nodesSurTable.count-1].premierPortail {
                nodesSurTable[nodesSurTable.count-1].noeud.removeFromParent()
                nodesSurTable.removeLast()
                deselectionnerTout()
                updateTextProprieteObjet()
            }
        }
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
    
    func creerMurTemporaire(position2: CGPoint){
        if table.containsPoint(posInitiale!) && table.containsPoint(position2) {
            let longeurMur = posInitiale?.distance(position2)
            let angleMur = posInitiale?.angle(position2)
            
            let objet = SKSpriteNode(imageNamed: "mur")
            objet.name = "temp"
            
            objet.size.width *= 0.15
            objet.size.height *= 0.15
            
            objet.position = posInitiale!.centre(position2)
            objet.zPosition = -14
            
            objet.size.width = longeurMur!
            objet.zRotation = angleMur!
            
            setPhysicsBody(objet, masque: 1) //Masque: 1 -> Objets sur la table
            
            objet.xScale *= scaleTable
            objet.yScale *= scaleTable
            
            self.addChild(objet)
            
            let temp = monObjet(noeud: objet)
            nodesSurTable.append(temp)
        }
    }
    
    func detruireMurTemporaire(){
        if construireMur {
            if nodesSurTable.count > 0 {
                if nodesSurTable[nodesSurTable.count-1].noeud.name == "temp" {
                    nodesSurTable[nodesSurTable.count-1].noeud.removeFromParent()
                    nodesSurTable.removeLast()
                }
            }
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
    
    func resetLaMap(){
        AudioServicesPlaySystemSound(sonSelectionOutil)
        Popups.SharedInstance.ShowAlert(self.viewController!,
            title: "Réinitialiser la zone",
            message: "Êtes-vous certains de vouloir réinitialiser la zone de jeu?",
            buttons: ["Réinitialiser" , "Annuler"]) { (buttonPressed) -> Void in
                if buttonPressed == "Réinitialiser" {
                    self.animationMagie()
                    AudioServicesPlaySystemSound(self.sonReset)
                    for objetCourant in self.nodesSurTable
                    {
                        let monNoeud = objetCourant.noeud
                        if self.nodesSelected.contains(monNoeud) {
                            self.savedSelected = self.savedSelected.filter {$0 != monNoeud}
                            self.nodesSurTable = self.nodesSurTable.filter {$0.noeud != monNoeud}
                            
                        }
                        self.unselectNode(monNoeud)
                        self.animationExplosion(monNoeud)
                        monNoeud.removeFromParent()
                    }
                    
                    if self.tutorielEnCours && self.etapeTutoriel == 4 {
                        self.tutoEtape5()
                    }
                } else if buttonPressed == "Annuler" {
                    //On fait rien sinon
                }
        }
    }
    
    ///Fonction qui resélectionne les noeurs de la sélection enregistrés (qui charge la sélection)
    ///- Actionné par le bouton loadSelect
    func loadSelect(){
        AudioServicesPlaySystemSound(sonSelectionOutil)
        nodesSelected = savedSelected
        if nodesSelected.count > 0
        {
            for node in nodesSelected
            {
                selectNode(node)
            }
            AudioServicesPlaySystemSound(sonSelection)
        }
    }
    
    ///Ce mode affiche un tutoriel à l'écran
    func modeTutoriel(){
        //On indique que le tutoriel a bien débuté
        if tutorielEnCours {
            //Message pour ajouter objet
            Popups.SharedInstance.ShowAlert(self.viewController!,
                title: "Annuler le tutoriel",
                message: "Êtes-vous certains de vouloir quitter le tutoriel?",
                buttons: ["Oui", "Non"]) { (buttonPressed) -> Void in
                    if buttonPressed == "Oui" {
                        self.tutoFin()
                    }
            }
            return
        }else{
            tutorielEnCours = true
        }
        
        //Création d'objets
        tutoEtape1()
        
        //Les étapes s'appellent entre eux
    }
    
    func tutoEtape1(){
        etapeTutoriel = 1 //Nous débutons la première étape
        
        //Message pour ajouter objet
        Popups.SharedInstance.ShowAlert(self.viewController!,
            title: "Ajout d'objets",
            message: "Cliquez sur un bouton d'objet puis cliquez sur la table pour créer un objet.\n\nNOTE: Les portails doivent être créés en paires en glissant le doigt et les murs doivent être créés en glissant le doigt.\n\nNOTE2: Vous pouvez quitter le tutoriel en tout temps en touchant à nouveau l'icone Tutoriel.",
            buttons: ["Ok"]) { (buttonPressed) -> Void in
        }
        
        //Fleche pointe bouton création objet
        fleche.position = CGPointMake(menuGauche.position.x + 200, menuDroit.position.y + 100)
        fleche.zPosition = 20
        fleche.zRotation =  CGFloat(180).degreeEnRadian
        self.addChild(fleche)
    }
    
    func tutoEtape2(){
        etapeTutoriel = 2
        
        //Message de félicitation
        Popups.SharedInstance.ShowAlert(self.viewController!,
            title: "Bravo",
            message: "Vous avez correctement ajouté un objet sur la table.",
            buttons: ["Ok"]) { (buttonPressed) -> Void in
                if buttonPressed == "Ok" {
                    //Flêche pointe l'objet sélectionné
                    self.fleche.position = CGPointMake(self.nodesSurTable[self.nodesSurTable.count-1].noeud.position.x + 100, self.nodesSurTable[self.nodesSurTable.count-1].noeud.position.y)
                    
                    //Faire une sélection
                    Popups.SharedInstance.ShowAlert(self.viewController!,
                        title: "Sélection",
                        message: "Sélectionnez un objet en le touchant.\n\nNote: Pour mieux voir les objets, vous pouvez effectuer un zoom vers l'avant en pinçant l'écran avec deux doigts.",
                        buttons: ["Ok "]) { (buttonPressed) -> Void in
                    }
                }
        }
    }
    
    func tutoEtape3(){
        etapeTutoriel = 3
        
        //Message de félicitation
        Popups.SharedInstance.ShowAlert(self.viewController!,
            title: "Bravo",
            message: "Vous avez correctement sélectionné un objet.",
            buttons: ["Ok"]) { (buttonPressed) -> Void in
                if buttonPressed == "Ok" {
                    
                    //Changer une propriété
                    Popups.SharedInstance.ShowAlert(self.viewController!,
                        title: "Propriétés",
                        message: "Modifier la propriété d'échelle de l'objet directement par le menu.\n\nNOTE: Il n'est possible de les modifier que lorsqu'exactement UN objet est sélectionné.",
                        buttons: ["Ok "]) { (buttonPressed) -> Void in
                            if buttonPressed == "Ok " {
                                //Flêche pointe les propriétés de l'objet en sélection
                                self.fleche.position = CGPointMake(self.menuDroit.position.x - 200, self.menuDroit.position.y + 250)
                                self.fleche.zRotation =  CGFloat(0).degreeEnRadian
                            }
                    }
                }
        }
    }
    
    func tutoEtape4(){
        etapeTutoriel = 4
        
        //Message de félicitation
        Popups.SharedInstance.ShowAlert(self.viewController!,
            title: "Bravo",
            message: "Vous avez correctement modifié une propriété.",
            buttons: ["Ok"]) { (buttonPressed) -> Void in
                if buttonPressed == "Ok" {
                    //Flêche pointe les outils
                    self.fleche.position = CGPointMake(self.menuGauche.position.x + 200, self.menuDroit.position.y - 200)
                    self.fleche.zRotation =  CGFloat(180).degreeEnRadian
                    
                    //Réinitialiser la partie
                    Popups.SharedInstance.ShowAlert(self.viewController!,
                        title: "Outils",
                        message: "Utitisez l'outil Réinitialisé pour réinitialiser la carte.\n\nNOTE: Vous pouvez remarquer dans cette section plusieurs outils très intéressants:\n1. La corbeille efface les objets sélectionnés\n2. La dupplication copie les objets en sélection.\n3. Le déplacement s'active/désactive pour bouger la vue.\n4. Sauvegarder sauvegarde la sélection en cours.\n5. Charger charge la sélection sauvegardé.\n6. Identiques sélectionne tous les objets identiques.",
                        buttons: ["Ok "]) { (buttonPressed) -> Void in
                            if buttonPressed == "Ok " {
                                
                            }
                    }
                }
        }
    }
    
    func tutoEtape5(){
        etapeTutoriel = 5
        
        //Message de félicitation
        Popups.SharedInstance.ShowAlert(self.viewController!,
            title: "Bravo",
            message: "Vous avez correctement réinitialisé la carte.",
            buttons: ["Ok"]) { (buttonPressed) -> Void in
                if buttonPressed == "Ok" {
                    
                    //Réinitialiser la partie
                    Popups.SharedInstance.ShowAlert(self.viewController!,
                        title: "Enregistrer",
                        message: "Vers le bas du menu droit, il est possible de revoir le tutoriel, d'enregistrer une zone de jeu et de quitter vers le menu.",
                        buttons: ["Ok "]) { (buttonPressed) -> Void in
                            if buttonPressed == "Ok " {
                                //Flêche pointe les outils
                                self.fleche.position = CGPointMake(self.menuDroit.position.x - 200, self.menuDroit.position.y - 200)
                                self.fleche.zRotation =  CGFloat(0).degreeEnRadian
                                
                                let delai = SKAction.waitForDuration(5)
                                self.runAction(delai, completion: {
                                    self.tutoFin() //Fin du tutoriel
                                })
                            }
                    }
                }
        }
    }
    
    func tutoFin(){
        //Message de félicitation
        Popups.SharedInstance.ShowAlert(self.viewController!,
            title: "Bravo",
            message: "Vous avez complété le tutoriel.",
            buttons: ["Ok"]) { (buttonPressed) -> Void in
        }
        
        etapeTutoriel = 0
        fleche.removeFromParent() //On enlève la flêche
        tutorielEnCours = false //Le tutoriel vient de terminer
    }
    
    ///Fonction qui efface les noeuds qui sont sélectionné
    ///- Actionné par le bouton delete
    func effacerNoeuds(){
        //Si on delete des nodes qui sont dans la sélection, on ne doit pas les resélectionné lors du chargement de la séleciton (ils n'existent plus).
        for objetCourant in nodesSurTable
        {
            let monNoeud = objetCourant.noeud
            if nodesSelected.contains(monNoeud) && monNoeud.name == "objetportail" {
                let index = nodesSurTable.indexOf { $0 === objetCourant }
                
                var portail2 = SKSpriteNode()
                if objetCourant.premierPortail {
                    portail2 = nodesSurTable[index!+1].noeud
                }else{
                    portail2 = nodesSurTable[index!-1].noeud
                }
                if !nodesSelected.contains(portail2) && portail2.name == "objetportail" {
                    savedSelected = savedSelected.filter {$0 != portail2}
                    nodesSurTable = nodesSurTable.filter {$0.noeud != portail2}
                    unselectNode(portail2)
                    animationExplosion(portail2)
                    portail2.removeFromParent()
                }
            }
        }
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
            //TODO: Changer l'accumulatedFrame par un test de collition physique...
            //On utilise l'accumulatedFrame pour prendre en compte la rotation et le scaling des objets
            let largeur = (noeud.calculateAccumulatedFrame().maxX - noeud.calculateAccumulatedFrame().minX)/2
            let hauteur = (noeud.calculateAccumulatedFrame().maxY - noeud.calculateAccumulatedFrame().minY)/2
            
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
        
        for objetCourant in nodesSurTable
        {
            let monNoeud = objetCourant.noeud
            if nodesSelected.contains(monNoeud) && monNoeud.name == "objetportail" {
                let index = nodesSurTable.indexOf { $0 === objetCourant }
                
                var portail2 = SKSpriteNode()
                if objetCourant.premierPortail {
                    portail2 = nodesSurTable[index!+1].noeud
                }else{
                    portail2 = nodesSurTable[index!-1].noeud
                }
                if !nodesSelected.contains(portail2) && portail2.name == "objetportail" {
                    selectNode(portail2)
                }
            }
        }
        
        for objetCourant in nodesSurTable {
            let node = objetCourant.noeud
            if nodesSelected.contains(node) {
                unselectNode(node)
                let nodeCopie = node.copy() as! SKSpriteNode
                let tempX = nodeCopie.xScale
                let tempY = nodeCopie.yScale
                nodeCopie.xScale /= nodeCopie.xScale
                nodeCopie.yScale /= nodeCopie.yScale
                setPhysicsBody(nodeCopie, masque: 1) //Masque: 1 -> Objets sur la table
                nodeCopie.xScale *= tempX
                nodeCopie.yScale *= tempY
                let nouvObjet = monObjet(noeud: nodeCopie)
                //nouvObjet.noeud.position.x += nouvObjet.noeud.size.width/2
                //nouvObjet.noeud.position.y += nouvObjet.noeud.size.height/2
                if surTable(nouvObjet.noeud.position, node: node){
                    nodesSurTable.append(nouvObjet)
                    nodesSurTable[nodesSurTable.count-1].scale = objetCourant.scale
                    self.addChild(nodeCopie)
                    selectNode(nodeCopie)
                    AudioServicesPlaySystemSound(sonObjSurTable)
                }
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
        AudioServicesPlaySystemSound(sonSelection)
    }
    
    /**
     Cette méthode permet de créer un objet sur la table de jeu.
     
     Entrée:
     - endroitSurTable: Endoit où l'objet sera créé, en coordonnée de la table
     
     Note importante:
     - Cette méthode utilise la variable de classe "nomObjet" pour fabriquer le bon objet
     */
    func creerObjet(endroitSurTable: CGPoint, typeObjet: String, longeurMur: CGFloat?=nil, angleMur: CGFloat?=nil, premierPortail: Bool?=false){
        let objet = SKSpriteNode(imageNamed: typeObjet)
        objet.name = "objet" + typeObjet
        
        objet.size.width *= 0.15
        objet.size.height *= 0.15
       
        objet.position = endroitSurTable

        objet.zPosition = -14
        
        //Pour la construction d'un mur
        if longeurMur != nil && angleMur != nil {
            if longeurMur! < 20 {
                return
            }
            objet.size.width = longeurMur!
            objet.zRotation = angleMur!
        }
        
        setPhysicsBody(objet, masque: 1) //Masque: 1 -> Objets sur la table
        
        objet.xScale *= scaleTable
        objet.yScale *= scaleTable
        
        self.addChild(objet)
        
        if premierPortail != nil {
            let temp = monObjet(noeud: objet, premierPortail: premierPortail!)
            nodesSurTable.append(temp)
        }else{
            let temp = monObjet(noeud: objet, premierPortail: false)
            nodesSurTable.append(temp)
        }
        
        AudioServicesPlaySystemSound(sonObjSurTable)
        
        if tutorielEnCours && etapeTutoriel == 1 {
            tutoEtape2()
        }
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
    
    func animationMagie() {
        if let fireParticles = SKEmitterNode(fileNamed: "resetMagic") {
            fireParticles.position = table.position
            fireParticles.particlePositionRange = CGVectorMake(table.frame.width,table.frame.height);
            addChild(fireParticles)
            //disparaitParMagie
            
            //On doit delete la mémoire relié aux particules après l'animation
            let delai = SKAction.waitForDuration(2)
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
            if name != "boutonportail" {
                construirePortail = false
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
        
        if tutorielEnCours && etapeTutoriel == 2 {
            tutoEtape3()
        }
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
                self.textPointsTri?.hidden = true
                self.textPointsCirc?.hidden = true
                self.textPointsCible?.hidden = true
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
                    self.textPointsTri?.hidden = false;
                    self.textPointsCirc?.hidden = false;
                    self.textPointsCible?.hidden = false;
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
        textPointsTri!.text = String(self.ptsButoirTri)
        textPointsCirc!.text = String(self.ptsButoirCirc)
        textPointsCible!.text = String(self.ptsCible)
       
        //nom de la carte
        //textSauvegarde!.text = (carte.getNom() as NSString).stringByDeletingPathExtension //note: on enleve l'extention ".xml" et on update le textView
        
        
        if nodesSelected.count == 1 {
            textPositionX!.text = NSString(format: "%.0f", nodesSelected[0].position.x) as String
            textPositionY!.text = NSString(format: "%.0f", nodesSelected[0].position.y) as String
            textRotation!.text = NSString(format: "%.01f", nodesSelected[0].zRotation.RadianEnDegree) as String
            for objet in nodesSurTable {
                if objet.noeud == nodesSelected[0] {
                    textScale!.text = NSString(format: "%.01f", objet.scale) as String
                }
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
            
            self.textPositionX?.enabled = false
            textPositionX!.backgroundColor = UIColor.grayColor()
            
            self.textPositionY?.enabled = false
            textPositionY!.backgroundColor = UIColor.grayColor()
            
            self.textRotation?.enabled = false
            textRotation!.backgroundColor = UIColor.grayColor()
            
            self.textScale?.enabled = false
            textScale!.backgroundColor = UIColor.grayColor()
        }
    }
    
    ///Reçoit un "enter" d'un text field (n'importe quel)
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
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
                            let largeurInitiale = objet.noeud.xScale
                            let hauteurInitiale = objet.noeud.yScale
                            objet.noeud.xScale = objet.noeud.xScale / objet.scale * sFloat
                            objet.noeud.yScale = objet.noeud.yScale / objet.scale * sFloat
                            if !surTable(objet.noeud.position, node: objet.noeud) {
                                objet.noeud.xScale = largeurInitiale
                                objet.noeud.yScale = hauteurInitiale
                            }else{
                                objet.scale = sFloat
                            }
                        }
                    }
                }
            }else{
                updateTextProprieteObjet()
            }
        }
        
        if(textPointsTri!.text! != ""){
            if let s = converter.numberFromString(textPointsTri!.text!) {
                let sInt = Int(s)
                ptsButoirTri = sInt
            }else{
                updateTextProprieteObjet()
            }
        }
        
        if(textPointsCirc!.text! != ""){
            if let s = converter.numberFromString(textPointsCirc!.text!) {
                let sInt = Int(s)
                ptsButoirCirc = sInt
            }else{
                updateTextProprieteObjet()
            }
        }
        
        if(textPointsCible!.text! != ""){
            if let s = converter.numberFromString(textPointsCible!.text!) {
                let sInt = Int(s)
                ptsCible = sInt
            }else{
                updateTextProprieteObjet()
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
        
        if(textDiff!.text! != ""){
            if let s = converter.numberFromString(textDiff!.text!) {
                let sInt = Int(s)
                coteDifficulte = sInt
            }else{
                updateTextProprieteObjet()
            }
        }

        if tutorielEnCours && etapeTutoriel == 3 {
            tutoEtape4()
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
        let sonResetURL = NSBundle.mainBundle().URLForResource("disparaitParMagie", withExtension: "mp3")
        AudioServicesCreateSystemSoundID(sonResetURL!, &sonReset)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
    
    ///Fonction qui initialise les text fields pour les propriétés
    func initLabels(){
        textPositionX = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMinY(self.frame)+47, width: 50, height: 20))
        self.view!.addSubview(textPositionX!)
        textPositionX!.backgroundColor = UIColor.grayColor()
        textPositionX!.delegate = self
        
        textPositionY = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMinY(self.frame)+47, width: 50, height: 20))
        self.view!.addSubview(textPositionY!)
        textPositionY!.backgroundColor = UIColor.grayColor()
        textPositionY!.delegate = self
        
        textScale = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMinY(self.frame)+87, width: 50, height: 20))
        self.view!.addSubview(textScale!)
        textScale!.backgroundColor = UIColor.grayColor()
        textScale!.delegate = self
        
        textRotation = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-130, y: CGRectGetMinY(self.frame)+123, width: 50, height: 20))
        self.view!.addSubview(textRotation!)
        textRotation!.backgroundColor = UIColor.grayColor()
        textRotation!.delegate = self
        
        textPointsTri = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMinY(self.frame)+188, width: 50, height: 20))
        self.view!.addSubview(textPointsTri!)
        textPointsTri!.backgroundColor = UIColor.whiteColor()
        textPointsTri!.delegate = self
        
        textPointsCirc = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMinY(self.frame)+227, width: 50, height: 20))
        self.view!.addSubview(textPointsCirc!)
        textPointsCirc!.backgroundColor = UIColor.whiteColor()
        textPointsCirc!.delegate = self
        
        textPointsCible = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMinY(self.frame)+266, width: 50, height: 20))
        self.view!.addSubview(textPointsCible!)
        textPointsCible!.backgroundColor = UIColor.whiteColor()
        textPointsCible!.delegate = self
        
        textBilleGratuite = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMinY(self.frame)+305, width: 50, height: 20))
        self.view!.addSubview(textBilleGratuite!)
        textBilleGratuite!.backgroundColor = UIColor.whiteColor()
        textBilleGratuite!.delegate = self
        
        textDiff = UITextField(frame: CGRect(x: CGRectGetMaxX(self.frame)-70, y: CGRectGetMinY(self.frame)+344, width: 50, height: 20))
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
        var noPortail = true
        for portail in carte.arbre.portail{
        
            let positionXML = CGPoint(x: portail.positionX!, y: portail.positionY!)
            let positionScene = table.convertPoint(positionXML, toNode: self)
            creerObjet(positionScene,typeObjet: portail.type!, premierPortail: noPortail)
            noPortail = !noPortail
            
            let nouvelObjet = nodesSurTable[nodesSurTable.count-1]
            //echelle
            nouvelObjet.scale = CGFloat(portail.echelle!)
            nouvelObjet.noeud.xScale *= nouvelObjet.scale/5
            nouvelObjet.noeud.yScale *= nouvelObjet.scale/5
            //objet.noeud.zRotation
            nouvelObjet.noeud.zRotation = CGFloat(portail.angleRotation!)
        }
        
        ///Creation des murs
        for mur in carte.arbre.mur{
            let positionXML = CGPoint(x: mur.positionX!, y: mur.positionY!)
            let positionScene = table.convertPoint(positionXML, toNode: self)
            creerObjet(positionScene,typeObjet: mur.type!)
            
            let nouvelObjet = nodesSurTable[nodesSurTable.count-1]
            //echelle
            nouvelObjet.noeud.size.width = CGFloat(mur.largeurMur!)
            setPhysicsBody(nouvelObjet.noeud,masque: 1)
            nouvelObjet.noeud.xScale *= nouvelObjet.scale/5
            //objet.noeud.zRotation
            nouvelObjet.noeud.zRotation = CGFloat(mur.angleRotation!)
        }
        
        ///Creation des autres objets
        for objet in carte.arbre.autresObjets{
            let positionXML = CGPoint(x: objet.positionX!, y: objet.positionY!)
            let positionScene = self.convertPoint(positionXML, fromNode: table)
            
            let typeObjetClientLeger = carte.dictionnaireObjetsXmlToLeger[objet.type!]
            creerObjet(positionScene,typeObjet: typeObjetClientLeger!)
            
            let nouvelObjet = nodesSurTable[nodesSurTable.count-1]
            //echelle
            nouvelObjet.scale = CGFloat(objet.echelle!)
            nouvelObjet.noeud.xScale *= nouvelObjet.scale/5
            nouvelObjet.noeud.yScale *= nouvelObjet.scale/5
            //objet.noeud.zRotation
            nouvelObjet.noeud.zRotation = CGFloat(objet.angleRotation!)
    
        }
        
    }
    
    ///Cree un objet de type Carte et la sauvegarde sous format xml
    func sauvegarderNouvelleCarte(){
        
        PopupsText.SharedInstance.ShowAlert(self.viewController!,
            title: "Sauvegarder Carte",
            message: "Choisissez un nom pour la zone de jeu",
            buttons: ["Sauvegarder" , "Annuler"], texteInitial: (self.carte.getNom() as NSString).stringByDeletingPathExtension) { (buttonPressed) -> Void in
                if buttonPressed == "Sauvegarder" {
                    if PopupsText.SharedInstance.getTextField() == "" {
                        Popups.SharedInstance.ShowAlert(self.viewController!,
                            title: "Échec",
                            message: "Le nom n'est pas valide. Échec de la sauvegarde.",
                            buttons: ["Ok"]) { (buttonPressed) -> Void in
                                
                        }
                        return
                    }
                    
                    self.carte.setNom("\(PopupsText.SharedInstance.getTextField())")
                    let nomNouvelleSauvegarde = "\(self.carte.getNom()).xml"
                    //self.carte = Carte(nom: nomNouvelleSauvegarde)
                    
                   // self.preparerCarteXML(self.carte)
                    
                    let parseur = ParseurXML()
                    
                    ///si le fichier n'existe pas deja
                    if !self.fichierExiste(nomNouvelleSauvegarde,listeDeURL: parseur.fichiersSauvegardeURLs){
                        
                        if let xmlString = self.carte.toXmlString(){
                            parseur.sauvegarderStringXML(xmlString, nomFichier: nomNouvelleSauvegarde)
                            Popups.SharedInstance.ShowAlert(self.viewController!,
                                title: "Réusite",
                                message: "La zone de jeu a bien été sauvegardé.",
                                buttons: ["Ok"]) { (buttonPressed) -> Void in
                                    
                            }
                        }
                    }
                    //si le fichier existe deja, on avertis que celui-ci seras ecrasé
                    else{
                        Popups.SharedInstance.ShowAlert(self.viewController!,
                            title: "Attention!",
                            message: "Le nom \"\(nomNouvelleSauvegarde)\"que vous avez choisis pour votre carte existe deja. Voulez vous ecraser le fichier existant sur le disque? Sinon modifiez le nom de la carte",
                            buttons: ["Écraser", "Annuler"]) { (buttonPressed) -> Void in
                                if buttonPressed == "Annuler" {
                                    //On fait rien sinon
                                } else if buttonPressed == "Écraser"{
                                    if let xmlString = self.carte.toXmlString(){
                                        parseur.sauvegarderStringXML(xmlString, nomFichier: nomNouvelleSauvegarde)
                                    }
                                }
                        }
                        
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
        
        //Initialiser l'arbre
        carte.arbre = Arbre()
        
        ///Ajouter une table
        carte.arbre.ajouterTable(0, posY: 0)
        
        //ajouter l'heure et date
        let nsDate = NSDate()
        let timeFormatter = NSDateFormatter()
        let dateFormatter = NSDateFormatter()
        timeFormatter.dateFormat = " HH:mm:ss"
        dateFormatter.dateFormat = "dd/MM/yyyy "
        let time = timeFormatter.stringFromDate(nsDate)
        let date = dateFormatter.stringFromDate(nsDate)
        carte.time = time
        carte.date = date
        
        ///enregistrer les objets de la scene
        for objet in nodesSurTable{
            
            let nom = objet.noeud.name!
            //convertir les coordones de scene en coordones
            let coordonnesTable = self.convertPoint(objet.noeud.position, toNode: table)
            
            switch  nom {
            case "objetmur":
                carte.arbre.ajouterMur(Int(coordonnesTable.x), posY: Int(coordonnesTable.y), largeurMur: Float(objet.noeud.size.width), angleRotation: Float(objet.noeud.zRotation))
            case "objetportail":
                carte.arbre.ajouterPortail(Int(coordonnesTable.x), posY: Int(coordonnesTable.y),
                    echellePortail: Float(objet.scale), angleRotation: Float(objet.noeud.zRotation))
            default:
                let nomObjet = nom.substringFromIndex(nom.startIndex.advancedBy(5))
                
                //Traduire le nom de l'objet
                let nomObjetXml = carte.dictionnaireObjetsLegerToXml[nomObjet]
                
                carte.arbre.ajouterAutreObjet(nomObjetXml!, posX: Int(coordonnesTable.x), posY: Int(coordonnesTable.y), echelleObjet: Float(objet.scale), angleRotation: Float(objet.noeud.zRotation))
            }
        }
    
    
    }
    
}
