//
//  AudioMixerHelper.swift
//  
//
//  Created by NoamSasunker on 12/23/18.
//

import UIKit
import AVFoundation


extension UIViewController{
    
    //func that gets path to directory
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func displayAlert(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func formattedCurrentTime(time: UInt, label:UILabel){
        let minutes = (time / 60) % 60
        let seconds = time % 60
        label.text = String(format: "%02i:%02i", arguments: [minutes, seconds])
    }
    
    func moveSlider(slider:UISlider, audioPlayer:AVAudioPlayer){
        slider.setValue(Float(audioPlayer.currentTime), animated: true)
    }
    
}
