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
    
    var userName:String
    var mixName:String
    var numberOfLikes:Int = 0
    
    init(userName:String, mixName:String) {
        self.userName = userName
        self.mixName = mixName
    }
}
