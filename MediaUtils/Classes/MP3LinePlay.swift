//
//  MP3LinePlay.swift
//  FlyIntimate
//
//  Created by 聂飞安 on 2020/9/18.
//  Copyright © 2020 nie. All rights reserved.
//

import UIKit
import AVFoundation
import NFAToolkit

@objc open class MP3LinePlay: NSObject {
    
    var player : AVPlayer!
    var isObserver = false
    var isPlaying = false
    @objc public var callBack: CB?
    @objc public var startBack: CB?
    
    public  func play(_ url : URL? ,_ defaultTime : Float64 = 0){
        if url == nil {
            return
        }
        self.player?.pause()
        removePlayMusicStatus()
        player?.currentItem?.cancelPendingSeeks()
        player?.currentItem?.asset.cancelLoading()
        
        let item = AVPlayerItem(asset: AVAsset(url:url!))
        if player != nil {
            self.player.replaceCurrentItem(with: item)
        }else{
            player = AVPlayer(playerItem: item)
        }
        addPlayMusicStatus()
        self.player?.play()
    }
    
   public func pause(){
       self.player?.pause()
        playFinished()
    }
    
    
    private func addPlayMusicStatus(){
       if !isObserver {
           //通过KVO监听播放器状态
           isObserver = true
            addNSNotificationForPlayMusicFinish()
           self.player.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
           addNSNotificationForPlayMusicFinish()
       }
    }
       
    private func addNSNotificationForPlayMusicFinish(){
           NotificationCenter.default.removeObserver(self)
           NotificationCenter.default.addObserver(self, selector: #selector(self.playFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
       }
    
       func removePlayMusicStatus(){
           if isObserver {
               isObserver = false
               self.player?.currentItem?.removeObserver(self, forKeyPath: "status")
           }
       }
    
    @objc func playFinished(){
        isPlaying = false
       callBack?()
    }
    
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status"{
              if let status = change?[NSKeyValueChangeKey.newKey] as? Int{
                  switch status {
                  case AVPlayer.Status.readyToPlay.rawValue :
                        isPlaying = true
                        startBack?()
                      break
                  default:
                    isPlaying = false
                    break
                  }
              }
          }
      }
    
    @objc public func getIsPlaying() -> Bool{
        return isPlaying
    }
}
