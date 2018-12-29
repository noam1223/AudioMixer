//
//  recordsTableViewCell.swift
//  Mixer
//
//  Created by NoamSasunker on 12/6/18.
//  Copyright © 2018 NoamSasunker. All rights reserved.
//

import UIKit
import AVFoundation
import ChameleonFramework
import FirebaseStorage


class recordsListViewController: UIViewController, AVAudioPlayerDelegate {
    
    var recordPlist = [audioMixer]()
    let recordListPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recording.plist")

    
    func loadRecords(){
        if let data = try? Data(contentsOf: recordListPath!){
            let decoder = PropertyListDecoder()
            do{
                recordPlist = try decoder.decode([audioMixer].self, from: data)
            } catch {
                print("ERROR TO LOAD RECORDS: \(error)")
            }
        }
    }
    
    @IBAction func backHome(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var numberOfRecords:Int = 0
    var soundTimer: CFTimeInterval = 0.0
    var updateTimer: CADisplayLink!


    
    @IBOutlet weak var countingTime: UILabel!
    @IBOutlet weak var maximumTimeRecord: UILabel!
    @IBOutlet weak var sliderTimeRecord: UISlider!
    @IBOutlet weak var recordsTableView: UITableView!
    
    @IBAction func sliderHasMoved(_ sender: UISlider) {
        if audioPlayer.isPlaying{
            audioPlayer.stop()
            audioPlayer.currentTime = TimeInterval(sliderTimeRecord.value)
            audioPlayer.play()
        }
    }
    
    @IBAction func Resume(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            return
        }
        audioPlayer.play()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.pause()
        }
        
    }
    
    @IBAction func restart(_ sender: UIButton) {
        if audioPlayer.isPlaying{
            audioPlayer.currentTime = 0
            audioPlayer.play()
        }else{
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecords()
        recordingSession = AVAudioSession.sharedInstance()
        recordsTableView.separatorStyle = .none
    }
    
    @objc func updateLoop() {
        if CFAbsoluteTimeGetCurrent() - soundTimer > 0.5 {
            formattedCurrentTime(time: UInt(audioPlayer.currentTime), label: countingTime)
            soundTimer = CFAbsoluteTimeGetCurrent()
            moveSlider(slider: sliderTimeRecord, audioPlayer: audioPlayer)
        }
    }
    
    func startUpdateLoop() {
        if updateTimer != nil {
            updateTimer.invalidate()
        }
        updateTimer = CADisplayLink(target: self, selector: #selector (updateLoop))
        updateTimer.preferredFramesPerSecond = 1
        updateTimer.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    }
    
    func getURLforMemo(fileName: String) -> NSURL {
        let tempDir = NSTemporaryDirectory()
        let filePath = tempDir + fileName
        
        return NSURL.fileURL(withPath: filePath) as NSURL
    }
    
    func downLoadSound(name:String) -> URL {
        let storageRef = Storage.storage().reference()
        let fileName = "/\(name).m4a"
        let imagesRef = storageRef.child("upload").child(fileName)
        let newfile = getURLforMemo(fileName: name)
        let uploadTask = imagesRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print(error) } else {
                if let d = data {
                    do {
                        try d.write(to: newfile as URL)
                        
                    } catch {
                            print(error)
                        
                    }
                }
            }
        }
        return newfile as URL
    }
    
    func stopUpdateLoop() {
        updateTimer.invalidate()
        updateTimer = nil
        // Update UI
        formattedCurrentTime(time: 0, label: countingTime)
    }
    
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if !flag{
//            stopUpdateLoop()
//        }
//    }
}


extension recordsListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordPlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        cell.textLabel?.text = recordPlist[indexPath.row].name!
        if let color = FlatMint().darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(recordPlist.count))){
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = downLoadSound(name: recordPlist[indexPath.row].name!)
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.delegate = self
            sliderTimeRecord.maximumValue = Float(audioPlayer.duration)
            formattedCurrentTime(time: UInt(audioPlayer.duration), label: maximumTimeRecord)
            audioPlayer.play()
            startUpdateLoop()
        } catch {
            displayAlert(title: "Ops!", message: "the play goes wrong")
            print(error)
        }
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete{
//            recordPlist.remove(at: indexPath.row)
//            
//            recordsTableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }

}
