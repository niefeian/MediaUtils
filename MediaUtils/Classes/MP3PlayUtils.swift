//
//  MP3PlayUtils.swift
//  FBSnapshotTestCase
//
//  Created by 聂飞安 on 2020/9/16.
//

import UIKit
import AVFoundation
import NFAToolkit

@objc open class MP3PlayUtils: NSObject, AVAudioPlayerDelegate {
    
    public static var once : MP3PlayUtils = MP3PlayUtils()
    @objc var player : AVAudioPlayer!
    @objc public var callBack: CB?
    @objc public var startBack: CB?
    
   @objc public class func initPay(_ path : String  , numberOfLoops : Int = 0) -> MP3PlayUtils{
        let mp3Player = MP3PlayUtils()
        mp3Player.initPay(path, numberOfLoops: numberOfLoops)
        return mp3Player
    }
    
    @objc public func initPay(_ path : String, numberOfLoops : Int = 0){
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player?.delegate = self
            player?.numberOfLoops = numberOfLoops
            player.delegate = self
        } catch _ {
        }
    }
    
    @objc public func play(_ path : String, playId : String, atTime : CGFloat = 0 , numberOfLoops : Int = 0) -> Bool{
        if  player != nil && player!.isPlaying{
            stopPlay(playId)
            return false
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player?.delegate = self
            player?.numberOfLoops = numberOfLoops
            player.delegate = self
            if player?.prepareToPlay() ?? false
            {
                player?.play(atTime: TimeInterval(exactly: atTime) ?? 0)
            }
        } catch let e {
            printLog(e)
        }
        return true
    }
    
    
    @objc public func pay(){
         if player?.prepareToPlay() ?? false
         {
             player.play()
         }
     }
     
    //停止播放
    @objc public func payStop() {
        player?.currentTime = TimeInterval(0)
        player?.stop()
        callBack?()
    }
    
    //重播
    @objc public func reloadPlayer(){
        player?.currentTime =  TimeInterval(0)
        player.play()
    }
    
    //获得状态
    @objc func getIsPlaying() -> Bool{
        return player?.isPlaying ?? false
    }
    
    
    private  func stopPlay(_ playId : String){
        player?.stop()
        callBack?()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "N.STOP_PLAY_AUDIO"), object: playId)
    }
    
    
    //播放网络音频
   @objc public func playUrl(_ url : String, playId : String , atTime : CGFloat = 0) -> Bool{
        if  player != nil && player!.isPlaying{
            stopPlay(playId)
            return false
        }
    
        func playsong(_ musicdata : Data){
            do{
                try player = AVAudioPlayer(data: musicdata)
                player?.prepareToPlay()
                player?.play(atTime: TimeInterval(exactly: atTime) ?? 0)
                player?.delegate = self
                startBack?()
            }catch {
            }
        }

        let configDefault = URLSessionConfiguration.default
        configDefault.timeoutIntervalForRequest = 15
        let session1 = URLSession(configuration: configDefault)
        let dataTask = session1.dataTask(with: URL(string: url)!, completionHandler: {(data,response,error)->Void in
            queueMainAsync(work: {
                if data != nil
                {
                     playsong(data!)
                }
            })
        })
        dataTask.resume()
        return true
    }
    
    
    //播放结束
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        callBack?()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "audioPlayerDidFinishPlaying"), object: nil)
    }
    
    //播放异常
    public func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        player.stop()
        callBack?()
    }
    
    //静音也要能播放
    public class func playback(_ category: AVAudioSession.Category = .playback){
        do {
          let session = AVAudioSession.sharedInstance()
          if #available(iOS 10.0, *) {
            try session.setCategory(category)
          }
          try session.setActive(true)
          UIApplication.shared.beginReceivingRemoteControlEvents()
      } catch { }
    }
    
    
}
