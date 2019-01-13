//
//  ShareRecordsCell.swift
//  Mixer
//
//  Created by NoamSasunker on 1/1/19.
//  Copyright © 2019 NoamSasunker. All rights reserved.
//

import UIKit

protocol RecordCellDelegate {
    func didBtnTrapped(name:String)
}

class shareRecordCell: UITableViewCell{
    
    var recordItem:audioMixer!
    var delegate:RecordCellDelegate?
    
    func setRecord(records:audioMixer){
        recordItem = records
        recordLabelView.text = records.name + "/" + records.address
    }
    
    @IBOutlet weak var recordLabelView: UILabel!
    
    @IBAction func btnTrapped(_ sender: UIButton) {
        delegate?.didBtnTrapped(name: recordItem.name)
    }
}



