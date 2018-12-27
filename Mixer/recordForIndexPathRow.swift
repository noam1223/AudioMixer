//
//  recordForIndexPathRow.swift
//  Mixer
//
//  Created by NoamSasunker on 12/12/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import Foundation

final class Shared {
    static let shared = Shared()
    
    var companyName : String!
    
}



class audioMixer{
    
    let name:String!
    let duration:TimeInterval!
    let isPlay:Bool = false
    
    
    init(name:String, duration:TimeInterval) {
        self.name = name
        self.duration = duration
    }
}

class audioMixerArray:audioMixer{
    
    let listOfRecords:[audioMixer] = []
    
}
