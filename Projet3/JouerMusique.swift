//
//  JouerMusique.swift
//  Projet3
//
//  Created by David Gourde on 15-11-17.
//  Copyright © 2015 David Gourde. All rights reserved.
//

import Foundation
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    
    //The location of the file and its type
    let url = NSBundle.mainBundle().URLForResource(filename, withExtension: "mp3")
    
    //Returns an error if it can't find the file name
    if (url == nil) {
        print("Could not find the file \(filename)")
    }
    
    let error: NSError? = nil
    
    //Assigns the actual music to the music player
    do{
        try backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: url!)
        
    }catch{
        print(error)
    }
    
    //Error if it failed to create the music player
    if backgroundMusicPlayer == nil {
        print("Could not create audio player: \(error!)")
        return
    }
    
    //A negative means it loops forever
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}
