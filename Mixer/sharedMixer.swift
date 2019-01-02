//
//  sharedMixer.swift
//  Mixer
//
//  Created by NoamSasunker on 1/1/19.
//  Copyright © 2019 NoamSasunker. All rights reserved.
//

import Foundation
import UIKit

class sharedRecord{
    
    var name:String
    var mixName:String
    var numberOfLikes:Int = 0
    
    init(name:String, mixName:String) {
        self.name = name
        self.mixName = mixName
    }
    
}
