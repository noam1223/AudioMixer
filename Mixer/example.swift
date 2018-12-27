//
//
//
//
//import UIKit
//import AVFoundation
//
//func mixAudio()
//{
//    let currentTime = CFAbsoluteTimeGetCurrent()
//    let composition = AVMutableComposition()
//    let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
//    let avAsset = AVURLAsset.init(url: getDirectory().appendingPathComponent("5.m4a"), options: nil)
//    print("\(avAsset)")
//    var tracks = avAsset.tracks(withMediaType: AVMediaType.audio)
//    let clipAudioTrack = tracks[0]
//    do {
//        try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, avAsset.duration), of: clipAudioTrack, at: kCMTimeZero)
//    }
//    catch _ {
//    }
//    let compositionAudioTrack1 = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
//    
//    let avAsset1 = AVURLAsset.init(url: getDirectory().appendingPathComponent("5.m4a"))
//    print(avAsset1)
//    
//    
//    var tracks1 = avAsset1.tracks(withMediaType: AVMediaType.audio)
//    let clipAudioTrack1 = tracks1[0]
//    do {
//        try compositionAudioTrack1?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, avAsset1.duration), ofTrack: clipAudioTrack1, atTime: kCMTimeZero)
//    }
//    catch _ {
//    }
//    var paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
//    let CachesDirectory = paths[0]
//    let strOutputFilePath = CachesDirectory.stringByAppendingString("/Fav")
//    print(" strOutputFilePath is \n \(strOutputFilePath)")
//    
//    let requiredOutputPath = CachesDirectory.stringByAppendingString("/Fav.m4a")
//    print(" requiredOutputPath is \n \(requiredOutputPath)")
//    
//    soundFile1 = NSURL.fileURLWithPath(requiredOutputPath)
//    print(" OUtput path is \n \(soundFile1)")
//    var audioDuration = avAsset.duration
//    var totalSeconds = CMTimeGetSeconds(audioDuration)
//    var hours = floor(totalSeconds / 3600)
//    var minutes = floor(totalSeconds % 3600 / 60)
//    var seconds = Int64(totalSeconds % 3600 % 60)
//    print("hours = \(hours), minutes = \(minutes), seconds = \(seconds)")
//    
//    let recordSettings:[String : AnyObject] = [
//        
//        AVFormatIDKey: Int(kAudioFormatMPEG4AAC) as AnyObject,
//        AVSampleRateKey: 12000 as AnyObject,
//        AVNumberOfChannelsKey: 1 as AnyObject,
//        AVEncoderAudioQualityKey: AVAudioQuality.Low.rawValue
//    ]
//    do {
//        audioRecorder = try AVAudioRecorder(URL: soundFile1, settings: recordSettings)
//        audioRecorder!.delegate = self
//        audioRecorder!.meteringEnabled = true
//        audioRecorder!.prepareToRecord()
//    }
//        
//    catch let error as NSError
//    {
//        audioRecorder = nil
//        print(error.localizedDescription)
//    }
//    
//    do {
//        
//        try FileManager.defaultManager().removeItemAtURL(soundFile1)
//    }
//    catch _ {
//    }
//    let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
//    exporter!.outputURL = soundFile1
//    exporter!.outputFileType = AVFileType.m4a
//    let duration = CMTimeGetSeconds(avAsset1.duration)
//    print(duration)
//    if (duration < 5.0) {
//        print("sound is not long enough")
//        return
//    }
//    // e.g. the first 30 seconds
//    let startTime = CMTimeMake(0, 1)
//    let stopTime = CMTimeMake(seconds,1)
//    let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
//    print(exportTimeRange)
//    exporter!.timeRange = exportTimeRange
//    print(exporter!.timeRange)
//}
//
//
//func getDirectory() -> URL{
//    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    let documentDirectory = paths[0]
//    return documentDirectory
//}

