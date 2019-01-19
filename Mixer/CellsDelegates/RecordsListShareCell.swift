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
    
    func setRecordShared(recordShared:sharedRecord, recordLikes:[String]){
        sharedItem = recordShared
        if recordLikes.contains(recordShared.mixName){
            likeBtn.isSelected = true
            if recordShared.numberOfLikes == 1{
                numberOfLikesLable.text = "You liked it"
            } else {
                numberOfLikesLable.text = "You and \(recordShared.numberOfLikes - 1)+"
            }
        } else {
            likeBtn.isSelected = false
            numberOfLikesLable.text = "\(recordShared.numberOfLikes)"
        }
        userNameLabel.text = recordShared.userName
        recordNameLabel.text = recordShared.mixName
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var recordNameLabel: UILabel!
    @IBOutlet weak var numberOfLikesLable: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    
    
    @IBAction func playTrapped(_ sender: UIButton) {
        delegate?.didPlayTrapped(name: sharedItem.mixName, userName: sharedItem.userName)
    }
    
    @IBAction func likeTrapped(_ sender: UIButton) {
        delegate?.didLikeTrapped(recordItem: sharedItem)
    }
    
}



