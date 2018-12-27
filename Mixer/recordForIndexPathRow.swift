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



class audioMixer: Codable{
    
    let name:String!
    
    init(name:String) {
        self.name = name
    }
}

