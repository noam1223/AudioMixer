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
    
    var companyName : String?
    
}

final class User{
    static let user = User()
    
    var userName:String!
    var email:String!
    var password:String!
    var firstTimeLoggedIn:Bool = false
}


class audioMixer: Codable{
    
    let name:String!
    let address:String!
    
    init(name:String, address:String) {
        self.name = name
        self.address = address
    }
}

