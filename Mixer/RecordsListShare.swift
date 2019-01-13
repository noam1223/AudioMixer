//
//  RecordsListShare.swift
//  Mixer
//
//  Created by NoamSasunker on 1/6/19.
//  Copyright © 2019 NoamSasunker. All rights reserved.
//

import UIKit


protocol RecordListShareCellDelegate {
    func didPlayTrapped(name:String, userName:String)
    func didLikeTrapped(recordItem:sharedRecord)
}

class RecordListShare: UITableViewCell {
    
    var sharedItem:sharedRecord!
    var delegate:RecordListShareCellDelegate?
    
    func setRecordShared(recordShared:sharedRecord){
        sharedItem = recordShared
        userNameLabel.text = recordShared.userName
        recordNameLabel.text = recordShared.mixName
        numberOfLikesLable.text = String(recordShared.numberOfLikes)
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var recordNameLabel: UILabel!
    @IBOutlet weak var numberOfLikesLable: UILabel!
    
    
    
    @IBAction func playTrapped(_ sender: UIButton) {
        delegate?.didPlayTrapped(name: sharedItem.mixName, userName: sharedItem.userName)
    }
    
    @IBAction func likeTrapped(_ sender: UIButton) {
        delegate?.didLikeTrapped(recordItem: sharedItem)
    }
    
}

class sharedRecord{
    
    var userName:String
    var mixName:String
    var numberOfLikes:Int = 0
    var arrayOfLike:[String] = []
    
    init(userName:String, mixName:String, numberOfLikes:Int) {
        self.userName = userName
        self.mixName = mixName
        self.numberOfLikes = numberOfLikes
    }
}

class DidLike{
    
    var userLike:String
    var likeOrdisLike:Bool = false
    
    init(userLike:String, likeOrdisLike:Bool) {
        self.userLike = userLike
        self.likeOrdisLike = likeOrdisLike
    }
}
